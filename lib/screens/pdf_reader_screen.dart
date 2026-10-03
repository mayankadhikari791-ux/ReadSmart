import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import '../models/book_model.dart';
import '../models/reader_settings_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/pdf_session_service.dart';
import '../widgets/pdf_reader_controls.dart';
import '../widgets/smart_dictionary_sheet.dart';
import '../widgets/reader_settings_sheet.dart';
import '../widgets/page_navigation_dialog.dart';
import '../widgets/bookmarks_sheet.dart';

/// ReadSmart E-Book Reader Screen
///
/// Features physical book aesthetics:
///   • Real PDF rendering via pdfx
///   • Book-like paper margins & realistic inner spine crease shadow
///   • Warm Paper (Sepia), Crisp Light, and Charcoal Dark modes
///   • 3-Zone tap navigation (Left 25% prev, Center 50% menu, Right 25% next)
///   • Auto-hiding controls with 4-second reading idle timer
///   • Smooth animated page curl transitions
///   • Minimal distraction footer with page progress & session time
///   • Chapter & page jump navigation dialog
///   • Bookmarks sheet with one-tap jump
///   • Dedicated Reader Settings panel (font size, line spacing, brightness, layout, themes)
class PdfReaderScreen extends StatefulWidget {
  final Book book;
  final AppState appState;
  final int? initialPage;

  const PdfReaderScreen({
    super.key,
    required this.book,
    required this.appState,
    this.initialPage,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen>
    with WidgetsBindingObserver {
  // ── PDF Controller ─────────────────────────────────────────────────────────
  PdfController? _pdfController;

  // ── State ──────────────────────────────────────────────────────────────────
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  String? _loadError;
  bool _controlsVisible = true;
  bool _isBookmarked = false;
  double _brightness = 0.0; // 0 = normal, 0.6 = dark overlay
  double _fontSize = 16.0;

  // ── Reader Settings & Theme ────────────────────────────────────────────────
  late ReadingThemeMode _themeMode;
  late ReaderSettings _readerSettings;

  // ── Session Timer ──────────────────────────────────────────────────────────
  late PdfSessionService _sessionService;
  bool _sessionSaved = false;

  // ── Auto-hide Controls Timer ───────────────────────────────────────────────
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _readerSettings = widget.appState.readerSettings;
    _themeMode = _readerSettings.themeMode;
    _fontSize = _readerSettings.fontSize;
    _brightness = _readerSettings.brightness;

    final target = widget.initialPage ?? widget.book.currentPage;
    _currentPage = (target > 0 ? target : 1);

    _sessionService = PdfSessionService(onTick: _onTimerTick);

    _initPdf();
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoHideTimer?.cancel();
    _pdfController?.dispose();
    _saveSessionOnExit();
    _sessionService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _sessionService.pause();
      _savePagePosition();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isLoading && _loadError == null) _sessionService.resume();
    }
  }

  // ── Auto-Hide Controls Timer ───────────────────────────────────────────────

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    if (_controlsVisible && _readerSettings.autoHideControls) {
      _autoHideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _controlsVisible) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _resetAutoHideTimer() {
    _startAutoHideTimer();
  }

  // ── PDF Initialization ─────────────────────────────────────────────────────

  Future<void> _initPdf() async {
    final path = widget.book.filePath;

    if (path == null || path.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError =
            'This book has no associated PDF file.\nPlease re-add it from your device.';
      });
      return;
    }

    try {
      final PdfDocument document;
      if (path.startsWith('assets/')) {
        document = await PdfDocument.openAsset(path);
      } else if (!kIsWeb) {
        if (!File(path).existsSync()) {
          setState(() {
            _isLoading = false;
            _loadError =
                'PDF file not found on device.\n\nThe file may have been moved or deleted:\n$path';
          });
          return;
        }
        document = await PdfDocument.openFile(path);
      } else {
        setState(() {
          _isLoading = false;
          _loadError =
              'Direct local file path ($path) cannot be loaded in Web browser sandbox.\nPlease upload your PDF using the "Add PDF" button.';
        });
        return;
      }

      _pdfController = PdfController(
        document: Future.value(document),
        initialPage: _currentPage,
      );

      final pages = document.pagesCount;

      setState(() {
        _totalPages = pages;
        _isLoading = false;
      });

      if (widget.book.totalPages != pages) {
        await widget.appState.updatePdfTotalPages(widget.book.id, pages);
      }

      _sessionService.start();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError =
            'Unable to open this PDF.\n\nThe file may be corrupted, password-protected, '
            'or in an unsupported format.\n\nDetails: ${e.toString().split('\n').first}';
      });
    }
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _onTimerTick() {
    if (mounted) setState(() {});

    if (_sessionService.elapsedSeconds % 60 == 0) {
      _savePagePosition();
    }
  }

  // ── Page Turn & Navigation ─────────────────────────────────────────────────

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() => _currentPage = page);
    _savePagePosition();
  }

  void _turnPage(int page) {
    final clamped = page.clamp(1, _totalPages);
    if (_readerSettings.transition == PageTransitionType.animatedCurl) {
      _pdfController?.animateToPage(
        clamped,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pdfController?.jumpToPage(clamped);
    }
    setState(() => _currentPage = clamped);
    _savePagePosition();
    _resetAutoHideTimer();
  }

  void _savePagePosition() {
    widget.appState.updateBookProgress(widget.book.id, _currentPage);
  }

  // ── 3-Zone Tap Navigation ──────────────────────────────────────────────────

  void _handleScreenTap(TapUpDetails details) {
    if (!_readerSettings.tapZonesEnabled) {
      _toggleControls();
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.25) {
      // Left 25%: Previous page
      if (_currentPage > 1) {
        _turnPage(_currentPage - 1);
      }
    } else if (tapX > screenWidth * 0.75) {
      // Right 25%: Next page
      if (_currentPage < _totalPages) {
        _turnPage(_currentPage + 1);
      }
    } else {
      // Center 50%: Toggle Controls
      _toggleControls();
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  // ── Session save ───────────────────────────────────────────────────────────

  Future<void> _saveSessionOnExit() async {
    if (_sessionSaved) return;
    _sessionSaved = true;

    final secs = _sessionService.stop();
    if (secs < 5) return;

    final startPage = widget.book.currentPage > 0 ? widget.book.currentPage : 1;
    final pagesRead = (_currentPage - startPage).abs();

    await widget.appState.completeAndSaveSession(
      bookId: widget.book.id,
      pagesRead: pagesRead > 0 ? pagesRead : 1,
      startPage: startPage,
      endPage: _currentPage,
    );
  }

  // ── Bookmark ───────────────────────────────────────────────────────────────

  Future<void> _toggleBookmark() async {
    _resetAutoHideTimer();
    setState(() => _isBookmarked = !_isBookmarked);
    if (_isBookmarked) {
      await widget.appState.saveBookmark(
        bookId: widget.book.id,
        page: _currentPage,
        title: 'Page $_currentPage — ${widget.book.title}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_rounded,
                    color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 8),
                Text('Bookmarked page $_currentPage'),
              ],
            ),
            backgroundColor: AppColors.darkCard,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // ── Settings & Sheets ──────────────────────────────────────────────────────

  void _openSettingsSheet() {
    _autoHideTimer?.cancel();
    ReaderSettingsSheet.show(
      context: context,
      settings: _readerSettings,
      onSettingsChanged: (newSettings) {
        setState(() {
          _readerSettings = newSettings;
          _themeMode = newSettings.themeMode;
          _fontSize = newSettings.fontSize;
          _brightness = newSettings.brightness;
        });
        widget.appState.updateReaderSettings(newSettings);
      },
    );
  }

  void _openPageJumpDialog() {
    _autoHideTimer?.cancel();
    PageNavigationDialog.show(
      context: context,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageSelected: (page) => _turnPage(page),
    );
  }

  void _openBookmarksSheet() {
    _autoHideTimer?.cancel();
    BookmarksSheet.show(
      context: context,
      bookId: widget.book.id,
      bookTitle: widget.book.title,
      currentPage: _currentPage,
      appState: widget.appState,
      onPageSelected: (page) => _turnPage(page),
    );
  }

  void _openDictionaryLookup([String? initialWord]) {
    _autoHideTimer?.cancel();
    final queryWord = (initialWord != null && initialWord.trim().isNotEmpty)
        ? initialWord.trim()
        : 'solitude';
    SmartDictionarySheet.show(
      context,
      word: queryWord,
      bookTitle: widget.book.title,
      pageNumber: _currentPage,
      appState: widget.appState,
      bookId: widget.book.id,
    );
  }

  void _onThemeChanged(ReadingThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _readerSettings = _readerSettings.copyWith(themeMode: mode);
    });
    widget.appState.updateReaderSettings(_readerSettings);
  }

  // ── UI Colors & Styles ─────────────────────────────────────────────────────

  Color get _readerBackground {
    switch (_themeMode) {
      case ReadingThemeMode.dark:
        return AppColors.darkBackground;
      case ReadingThemeMode.light:
        return AppColors.lightBackground;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaBackground;
    }
  }

  Color get _appBarBackground {
    switch (_themeMode) {
      case ReadingThemeMode.dark:
        return AppColors.darkSurface;
      case ReadingThemeMode.light:
        return AppColors.lightSurface;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaSurface;
    }
  }

  Color get _appBarForeground {
    switch (_themeMode) {
      case ReadingThemeMode.dark:
        return AppColors.textWhite;
      case ReadingThemeMode.light:
        return AppColors.lightText;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaText;
    }
  }

  SystemUiOverlayStyle get _systemOverlay {
    switch (_themeMode) {
      case ReadingThemeMode.dark:
        return SystemUiOverlayStyle.light;
      case ReadingThemeMode.light:
      case ReadingThemeMode.sepia:
        return SystemUiOverlayStyle.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlay,
      child: Scaffold(
        backgroundColor: _readerBackground,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleScreenTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Main PDF View ─────────────────────────────────────────────
              if (_isLoading)
                _buildLoadingView()
              else if (_loadError != null)
                _buildErrorView(_loadError!)
              else
                _buildPdfView(),

              // ── Minimal Distraction Reading Footer (when controls hidden) ──
              if (!_controlsVisible &&
                  !_isLoading &&
                  _loadError == null &&
                  _readerSettings.showFooter)
                _buildMinimalFooter(),

              // ── Brightness Dimming Overlay ─────────────────────────────────
              if (_brightness > 0 && !_isLoading && _loadError == null)
                IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: _brightness),
                  ),
                ),

              // ── Top App Bar ───────────────────────────────────────────────
              if (_controlsVisible && !_isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopBar(),
                ),

              // ── Bottom Controls Overlay ───────────────────────────────────
              if (_controlsVisible && !_isLoading && _loadError == null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PdfReaderControls(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    brightness: _brightness,
                    themeMode: _themeMode,
                    isBookmarked: _isBookmarked,
                    isTimerRunning: _sessionService.isRunning,
                    elapsedTime: _sessionService.formattedElapsed,
                    fontSize: _fontSize,
                    onPageChanged: _turnPage,
                    onBrightnessChanged: (v) {
                      _resetAutoHideTimer();
                      setState(() {
                        _brightness = v;
                        _readerSettings =
                            _readerSettings.copyWith(brightness: v);
                      });
                      widget.appState.updateReaderSettings(_readerSettings);
                    },
                    onThemeChanged: _onThemeChanged,
                    onBookmarkToggled: _toggleBookmark,
                    onTimerToggled: () {
                      _resetAutoHideTimer();
                      if (_sessionService.isRunning) {
                        _sessionService.pause();
                      } else {
                        _sessionService.resume();
                      }
                      setState(() {});
                    },
                    onFontSizeChanged: (size) {
                      _resetAutoHideTimer();
                      setState(() {
                        _fontSize = size;
                        _readerSettings =
                            _readerSettings.copyWith(fontSize: size);
                      });
                      widget.appState.updateReaderSettings(_readerSettings);
                    },
                    onDictionaryToggled: _openDictionaryLookup,
                    onSettingsToggled: _openSettingsSheet,
                    onNavigationToggled: _openPageJumpDialog,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-Widgets ────────────────────────────────────────────────────────────

  Widget _buildLoadingView() {
    final isDark = _themeMode == ReadingThemeMode.dark;
    final textColor = isDark ? AppColors.textWhite : AppColors.lightText;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.primaryGold,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.book.author,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    final textColor = _themeMode == ReadingThemeMode.dark
        ? AppColors.textWhite
        : AppColors.lightText;
    final mutedColor = _themeMode == ReadingThemeMode.dark
        ? AppColors.textMuted
        : AppColors.lightTextMuted;
    final cardColor = _themeMode == ReadingThemeMode.dark
        ? AppColors.darkCard
        : AppColors.lightCard;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.dangerRed.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_rounded,
                          size: 56,
                          color: AppColors.dangerRed.withValues(alpha: 0.7)),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to Open PDF',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 13,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.library_books_rounded, size: 16),
                        label: const Text('Back to Library'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfView() {
    final edgePadding = _controlsVisible
        ? EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
            bottom: 210,
          )
        : EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: _readerSettings.showFooter ? 34 : 8,
          );

    final marginPadding = _readerSettings.layout.padding;
    final isBookLike = _readerSettings.layout == PageMarginLayout.bookLike;
    final isDark = _themeMode == ReadingThemeMode.dark;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: edgePadding,
      child: Padding(
        padding: marginPadding,
        child: Stack(
          children: [
            // Paper Container
            Container(
              decoration: BoxDecoration(
                color: _readerBackground,
                borderRadius: BorderRadius.circular(isBookLike ? 6 : 0),
                boxShadow: isBookLike
                    ? [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: PdfView(
                controller: _pdfController!,
                onPageChanged: _onPageChanged,
                onDocumentError: (error) {
                  if (mounted) {
                    setState(() {
                      _loadError = 'Failed to render PDF.\n${error.toString()}';
                    });
                  }
                },
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.primaryGold),
                        const SizedBox(height: 12),
                        Text('Loading PDF…',
                            style: TextStyle(
                                color: _themeMode == ReadingThemeMode.dark
                                    ? AppColors.textMuted
                                    : AppColors.lightTextMuted)),
                      ],
                    ),
                  ),
                  pageLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  ),
                  errorBuilder: (_, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.dangerRed, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            'Page render error: $error',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                scrollDirection: _readerSettings.transition ==
                        PageTransitionType.verticalContinuous
                    ? Axis.vertical
                    : Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: _readerBackground),
              ),
            ),

            // Physical Book Spine Shadow (inner crease gradient on left edge)
            if (isBookLike)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 18,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(6)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalFooter() {
    final progress =
        _totalPages > 0 ? ((_currentPage / _totalPages) * 100).toInt() : 0;
    final isDark = _themeMode == ReadingThemeMode.dark;
    final textColor = isDark ? Colors.white54 : Colors.black45;

    return Positioned(
      bottom: 8,
      left: 18,
      right: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.book.title,
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                fontFamily: 'serif',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Page $_currentPage of $_totalPages • $progress%',
            style: TextStyle(
              color: textColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _sessionService.formattedElapsed,
            style: TextStyle(
              color: AppColors.primaryGold.withValues(alpha: 0.8),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final progress = _totalPages > 0
        ? (_currentPage / _totalPages).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _appBarBackground,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              child: Row(
                children: [
                  // Back to Library
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded,
                        color: _appBarForeground, size: 22),
                    tooltip: 'Back to Library',
                    onPressed: () async {
                      await _saveSessionOnExit();
                      if (mounted) Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: TextStyle(
                            color: _appBarForeground,
                            fontFamily: 'serif',
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.book.author,
                          style: TextStyle(
                            color: _appBarForeground.withValues(alpha: 0.65),
                            fontSize: 11.5,
                            fontFamily: 'sans-serif',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Bookmark current page toggle
                  IconButton(
                    icon: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _isBookmarked
                          ? AppColors.primaryGold
                          : _appBarForeground.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    tooltip: _isBookmarked ? 'Remove Bookmark' : 'Bookmark Page',
                    onPressed: _toggleBookmark,
                  ),

                  // Saved Bookmarks Drawer
                  IconButton(
                    icon: Icon(
                      Icons.bookmarks_outlined,
                      color: _appBarForeground.withValues(alpha: 0.75),
                      size: 21,
                    ),
                    tooltip: 'Saved Bookmarks',
                    onPressed: _openBookmarksSheet,
                  ),

                  // Display & Appearance Settings
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: _appBarForeground.withValues(alpha: 0.75),
                      size: 21,
                    ),
                    tooltip: 'Display Settings',
                    onPressed: _openSettingsSheet,
                  ),
                ],
              ),
            ),
            // Ultra-subtle reading progress hairline
            SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold.withValues(alpha: 0.85),
                ),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
