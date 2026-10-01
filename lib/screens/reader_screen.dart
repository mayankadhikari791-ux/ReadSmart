import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_dictionary_sheet.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  final AppState appState;
  final int? initialPage;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.appState,
    this.initialPage,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _showControls = true;
  bool _isBookmarked = true;
  double _brightness = 0.85;

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    // Determine current theme colors
    Color bgColor;
    Color textColor;
    switch (state.themeMode) {
      case ReadingThemeMode.dark:
        bgColor = const Color(0xFF141414);
        textColor = AppColors.textWarmParchment;
        break;
      case ReadingThemeMode.sepia:
        bgColor = AppColors.sepiaBackground;
        textColor = AppColors.sepiaText;
        break;
      case ReadingThemeMode.light:
        bgColor = AppColors.lightBackground;
        textColor = AppColors.lightText;
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Dimming Overlay controlled by brightness slider
            if (_brightness < 1.0)
              IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: (1.0 - _brightness) * 0.7),
                ),
              ),
            // 1. Reading Canvas / Novel Page
            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    // Chapter Title Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Chapter 7',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The Soul of the World',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 32,
                            height: 2,
                            color: AppColors.primaryGold.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Realistic Novel Prose Passage
                    _buildParagraph(
                      'The desert was full of mysterious omens. The boy watched the hawks hovering in the sky, observing how they made their circles with silent precision. In the distance, the wind whispered across the dunes, carrying secrets from centuries past.',
                      textColor,
                      state.readerFontSize,
                      isFirst: true,
                    ),

                    const SizedBox(height: 18),

                    // Interactive Word Highlight Sentence
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: state.readerFontSize,
                          height: 1.75,
                          color: textColor,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                '“In order to find the treasure, you will have to follow the ',
                          ),
                          // Tapable word "omens"
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                SmartDictionarySheet.show(
                                  context,
                                  word: 'Omens',
                                  bookTitle: widget.book.title,
                                  pageNumber: widget.book.currentPage,
                                  appState: state,
                                  bookId: widget.book.id,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(3),
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: AppColors.primaryGold,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'omens',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGold,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. God has prepared a path for everyone to follow. You just have to read the signs that he wrote for you.”',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildParagraph(
                      'The boy remembered what the old king had told him. There was a language in the world that everyone understood, a language the boy had used all that time that he was trying to improve things at the crystal shop.',
                      textColor,
                      state.readerFontSize,
                    ),

                    const SizedBox(height: 18),

                    _buildParagraph(
                      'It was the language of enthusiasm, of things accomplished with love and purpose, as part of a search for something believed in and desired. Tangier was no longer a strange city, and he felt that, just as he had conquered this place, he could conquer the world.',
                      textColor,
                      state.readerFontSize,
                    ),

                    const SizedBox(height: 18),

                    // Another tapable word "alchemist"
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: state.readerFontSize,
                          height: 1.75,
                          color: textColor,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'He turned his gaze toward the solitary figure of the ',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                SmartDictionarySheet.show(
                                  context,
                                  word: 'Alchemist',
                                  bookTitle: widget.book.title,
                                  pageNumber: widget.book.currentPage,
                                  appState: state,
                                  bookId: widget.book.id,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(3),
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: AppColors.primaryGold,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'alchemist',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGold,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ', who nodded in quiet understanding. Lead was meant to suffer its own transmutation until it became pure gold.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 2. Top Reading Toolbar (Collapsible)
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414).withValues(alpha: 0.92),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Page ${widget.book.currentPage} of ${widget.book.totalPages} • 4 min left',
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.primaryGold,
                        ),
                        onPressed: () {
                          setState(() => _isBookmarked = !_isBookmarked);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isBookmarked
                                  ? 'Bookmark added'
                                  : 'Bookmark removed'),
                              duration: const Duration(milliseconds: 600),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Floating Bottom Controls HUD (Collapsible)
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818).withValues(alpha: 0.96),
                    border: const Border(
                      top: BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Font scale, Theme switcher, Session timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Font scaling
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.text_decrease,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  state.setReaderFontSize(state.readerFontSize - 1);
                                },
                              ),
                              Text(
                                '${state.readerFontSize.toInt()}sp',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              IconButton(
                                icon: const Icon(Icons.text_increase,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  state.setReaderFontSize(state.readerFontSize + 1);
                                },
                              ),
                            ],
                          ),

                          // Brightness control
                          IconButton(
                            icon: Icon(
                              _brightness < 0.9 ? Icons.brightness_medium : Icons.brightness_high,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _brightness = _brightness == 1.0 ? 0.75 : (_brightness == 0.75 ? 0.55 : 1.0);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Screen brightness: ${(_brightness * 100).toInt()}%'),
                                  duration: const Duration(milliseconds: 600),
                                ),
                              );
                            },
                          ),

                          // Theme Toggle (Dark / Sepia / Light)
                          Row(
                            children: [
                              _buildThemeButton('D', ReadingThemeMode.dark, state),
                              const SizedBox(width: 6),
                              _buildThemeButton('S', ReadingThemeMode.sepia, state),
                              const SizedBox(width: 6),
                              _buildThemeButton('L', ReadingThemeMode.light, state),
                            ],
                          ),

                          // Session indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.schedule,
                                    color: AppColors.primaryGold, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '24 min',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Page Scrubber Slider
                      Row(
                        children: [
                          Text(
                            'p. ${widget.book.currentPage}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primaryGold,
                                inactiveTrackColor: Colors.grey.shade800,
                                thumbColor: AppColors.primaryGold,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: widget.book.currentPage.toDouble(),
                                min: 1,
                                max: widget.book.totalPages.toDouble(),
                                onChanged: (val) {
                                  setState(() {
                                    widget.book.currentPage = val.toInt();
                                  });
                                },
                              ),
                            ),
                          ),
                          Text(
                            '${widget.book.totalPages}p',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(
    String text,
    Color textColor,
    double fontSize, {
    bool isFirst = false,
  }) {
    return SelectableText(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: fontSize,
        height: 1.75,
        color: textColor,
      ),
      contextMenuBuilder: (context, editableTextState) {
        final textEditingValue = editableTextState.textEditingValue;
        final selected = textEditingValue.selection.textInside(textEditingValue.text).trim();
        final buttonItems = editableTextState.contextMenuButtonItems;

        if (selected.isNotEmpty) {
          buttonItems.insert(
            0,
            ContextMenuButtonItem(
              label: 'Smart Dictionary',
              onPressed: () {
                ContextMenuController.removeAny();
                SmartDictionarySheet.show(
                  context,
                  word: selected,
                  bookTitle: widget.book.title,
                  pageNumber: widget.book.currentPage,
                  appState: widget.appState,
                  bookId: widget.book.id,
                );
              },
            ),
          );
        }

        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
    );
  }

  Widget _buildThemeButton(
    String label,
    ReadingThemeMode mode,
    AppState state,
  ) {
    final isSelected = state.themeMode == mode;
    return InkWell(
      onTap: () => state.setThemeMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkCard,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
