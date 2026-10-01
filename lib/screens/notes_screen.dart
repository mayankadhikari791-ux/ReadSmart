import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/book_model.dart';
import '../models/vocabulary_word_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_widget.dart';
import 'pdf_reader_screen.dart';
import 'reader_screen.dart';

/// ReadSmart Book-Specific Vocabulary Notes Screen
///
/// Provides strict book-level isolation for vocabulary notes.
/// Features:
///   • Strict book tabs ("All Books", "The Alchemist Notes", "Atomic Habits Notes", etc.)
///   • Live Search (words, definitions, Hindi, regional meaning, personal notes)
///   • Page filter (filter words found on specific pages)
///   • Review vocabulary mode (interactive flashcard study session)
///   • Open original book page in PDF/e-book reader
///   • Edit note dialog (definitions and personal reflections)
///   • Copy meaning to clipboard
///   • Delete note with instant Undo support
class NotesScreen extends StatefulWidget {
  final AppState appState;
  final String? initialBookId;

  const NotesScreen({
    super.key,
    required this.appState,
    this.initialBookId,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _selectedBookFilter = 'All';
  int? _selectedPageFilter;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialBookId != null) {
      final book = widget.appState.books.firstWhere(
        (b) => b.id == widget.initialBookId,
        orElse: () => widget.appState.currentlyReadingBook,
      );
      _selectedBookFilter = book.title;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final booksWithNotes = state.uniqueBooksWithNotes;

        // Determine active collection or notes
        final List<VocabularyWord> displayedNotes = _getFilteredNotes(state);
        final availablePages = _getAvailablePages(state);

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: l10n.notesSearchHint,
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                  )
                : Text(
                    _selectedBookFilter == 'All'
                        ? (l10n.notesTitle)
                        : '$_selectedBookFilter Notes',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: AppColors.primaryGold,
                ),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
              if (displayedNotes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.school, color: AppColors.primaryGold),
                  tooltip: l10n.notesFlashcards,
                  onPressed: () => _openFlashcardReview(context, displayedNotes),
                ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Tabs / Filter
              _buildBookFilterBar(booksWithNotes, state),

              // Page Filter Bar (if available)
              if (availablePages.isNotEmpty)
                _buildPageFilterBar(availablePages),

              const Divider(color: AppColors.darkBorder, height: 1),

              // Content Area
              Expanded(
                child: displayedNotes.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        children: [
                          if (_selectedBookFilter == 'All') ...[
                            // Render book-by-book sections strictly isolated
                            for (final bookTitle in booksWithNotes)
                              ..._buildBookSection(bookTitle, displayedNotes, state),
                          ] else ...[
                            // Single book's notes with collection header
                            _buildSingleBookHeader(_selectedBookFilter, displayedNotes.length),
                            for (final note in displayedNotes)
                              _buildVocabularyCard(note, state),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Filter Logic ──────────────────────────────────────────────────────────

  List<VocabularyWord> _getFilteredNotes(AppState state) {
    List<VocabularyWord> list;
    if (_selectedBookFilter == 'All') {
      list = state.allVocabularyNotes;
    } else {
      list = state.notesForBook(_selectedBookFilter);
    }

    if (_selectedPageFilter != null) {
      list = list.where((n) => n.pageNumber == _selectedPageFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((n) {
        final matchesWord = n.word.toLowerCase().contains(q);
        final matchesEn = n.englishMeaning.toLowerCase().contains(q);
        final matchesHi = n.hindiMeaning.toLowerCase().contains(q) ||
            n.hindiWord.toLowerCase().contains(q);
        final matchesLang =
            n.selectedLangMeaning?.toLowerCase().contains(q) ?? false;
        final matchesNote = n.userNote?.toLowerCase().contains(q) ?? false;
        return matchesWord || matchesEn || matchesHi || matchesLang || matchesNote;
      }).toList();
    }

    return list;
  }

  List<int> _getAvailablePages(AppState state) {
    List<VocabularyWord> source;
    if (_selectedBookFilter == 'All') {
      source = state.allVocabularyNotes;
    } else {
      source = state.notesForBook(_selectedBookFilter);
    }
    final pages = source.map((n) => n.pageNumber).where((p) => p > 0).toSet().toList();
    pages.sort();
    return pages;
  }

  // ─── UI Components ─────────────────────────────────────────────────────────

  Widget _buildBookFilterBar(List<String> booksWithNotes, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.darkBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BOOK COLLECTIONS:',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              if (_selectedBookFilter != 'All')
                Text(
                  'Strict Book Isolation Active',
                  style: TextStyle(
                    color: AppColors.primaryGold.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  title: 'All Books',
                  filterValue: 'All',
                  count: state.allVocabularyNotes.length,
                ),
                for (final bookTitle in booksWithNotes) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    title: bookTitle,
                    filterValue: bookTitle,
                    count: state.notesForBook(bookTitle).length,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFilterBar(List<int> availablePages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: AppColors.darkCard.withValues(alpha: 0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            const Text(
              'Page:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('All Pages', style: TextStyle(fontSize: 11)),
              selected: _selectedPageFilter == null,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.darkCardElevated,
              labelStyle: TextStyle(
                color: _selectedPageFilter == null ? Colors.black : AppColors.textMuted,
                fontWeight: _selectedPageFilter == null ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _selectedPageFilter = null),
            ),
            for (final page in availablePages) ...[
              const SizedBox(width: 6),
              ChoiceChip(
                label: Text('Page $page', style: const TextStyle(fontSize: 11)),
                selected: _selectedPageFilter == page,
                selectedColor: AppColors.primaryGold,
                backgroundColor: AppColors.darkCardElevated,
                labelStyle: TextStyle(
                  color: _selectedPageFilter == page ? Colors.black : AppColors.textMuted,
                  fontWeight: _selectedPageFilter == page ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedPageFilter = selected ? page : null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String title,
    required String filterValue,
    required int count,
  }) {
    final isSelected = _selectedBookFilter == filterValue;
    return InkWell(
      onTap: () => setState(() {
        _selectedBookFilter = filterValue;
        _selectedPageFilter = null; // reset page filter on book change
      }),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSingleBookHeader(String title, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title Notes Collection',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Exclusive notes for this book • $count words saved',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookSection(
    String bookTitle,
    List<VocabularyWord> allNotes,
    AppState state,
  ) {
    final bookWords = allNotes
        .where((n) =>
            n.bookTitle.trim().toLowerCase() == bookTitle.trim().toLowerCase())
        .toList();
    if (bookWords.isEmpty) return [];
    return [_buildBookNotesSection(bookTitle, bookWords, state)];
  }

  Widget _buildBookNotesSection(
    String bookTitle,
    List<VocabularyWord> notes,
    AppState state,
  ) {
    final isAlchemist = bookTitle.toLowerCase().contains('alchemist');
    final accentColor = isAlchemist ? AppColors.primaryGold : AppColors.infoBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_stories, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$bookTitle Notes'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '${notes.length} words',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        for (final note in notes) _buildVocabularyCard(note, state),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVocabularyCard(VocabularyWord note, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word & Date Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      note.word,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    if (note.pronunciation.isNotEmpty)
                      Text(
                        note.pronunciation,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '🗓 ${note.dateSaved}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Badges Row (Language, Level, Page Jump button)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '🇺🇸 EN',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '🇮🇳 HI',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (note.selectedLangMeaning != null &&
                  note.selectedLangMeaning!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '🌐 ${(note.selectedLangCode ?? "LANG").toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.infoBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(
                note.cefrLevel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                ),
              ),
              const Spacer(),
              // Open Original Page Button
              InkWell(
                onTap: () => _openOriginalBookPage(note, state),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book, size: 12, color: AppColors.primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        'Page ${note.pageNumber}',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // English Definition
          Text(
            note.englishMeaning,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 13.5,
              height: 1.4,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 8),

          // Hindi Meaning Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.hindiWord.isNotEmpty) ...[
                  Text(
                    note.hindiWord,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  note.hindiMeaning,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Regional / Target Language Meaning (if present)
          if (note.selectedLangMeaning != null &&
              note.selectedLangMeaning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meaning in ${(note.selectedLangCode ?? "Selected Language").toUpperCase()}:',
                    style: const TextStyle(
                      color: AppColors.infoBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.selectedLangMeaning!,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // User Personal Note (if exists)
          if (note.userNote != null && note.userNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2616),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondaryAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2, size: 14, color: AppColors.secondaryAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note.userNote!,
                      style: const TextStyle(
                        color: AppColors.textWarmParchment,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Context Quote
          if (note.exampleSentence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.textMuted, width: 2),
                ),
              ),
              child: Text(
                note.exampleSentence,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ),
          ],

          const Divider(color: AppColors.darkBorder, height: 18),

          // Actions Row (Copy, Edit, Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Book: ${note.bookTitle}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    color: AppColors.textMuted,
                    tooltip: 'Copy Meaning',
                    onPressed: () => _copyNoteMeaning(context, note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: AppColors.textMuted,
                    tooltip: 'Edit Note',
                    onPressed: () => _showEditNoteDialog(context, note, state),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.dangerRed.withValues(alpha: 0.8),
                    tooltip: 'Delete Note',
                    onPressed: () => _deleteNoteWithUndo(context, note, state),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    final title = _searchQuery.isNotEmpty
        ? 'No notes match "$_searchQuery"'
        : (l10n.notesNoNotes);
    final message = _selectedBookFilter == 'All'
        ? (l10n.notesNoNotesHint)
        : 'Save words from "$_selectedBookFilter" to see them here.';

    return EmptyStateWidget(
      icon: Icons.menu_book_rounded,
      title: title,
      message: message,
    );
  }

  // ─── Actions & Modals ──────────────────────────────────────────────────────

  void _openOriginalBookPage(VocabularyWord note, AppState state) {
    // 1. Find book by ID or title
    final book = state.books.firstWhere(
      (b) =>
          b.id == note.bookId ||
          b.title.trim().toLowerCase() == note.bookTitle.trim().toLowerCase(),
      orElse: () => Book(
        id: note.bookId,
        title: note.bookTitle,
        author: 'Unknown',
        totalPages: 100,
        currentPage: note.pageNumber,
        coverGradient: const [Color(0xFF1A237E), Color(0xFF4A148C)],
      ),
    );

    // 2. Open reader at specified page
    if (book.isPdf) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfReaderScreen(
            book: book,
            appState: state,
            initialPage: note.pageNumber,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            book: book,
            appState: state,
            initialPage: note.pageNumber,
          ),
        ),
      );
    }
  }

  void _copyNoteMeaning(BuildContext context, VocabularyWord note) {
    final buffer = StringBuffer();
    buffer.writeln('${note.word} ${note.pronunciation}');
    buffer.writeln('English: ${note.englishMeaning}');
    if (note.hindiMeaning.isNotEmpty) {
      buffer.writeln('Hindi: ${note.hindiWord} - ${note.hindiMeaning}');
    }
    if (note.selectedLangMeaning != null && note.selectedLangMeaning!.isNotEmpty) {
      buffer.writeln('${note.selectedLangCode ?? "Meaning"}: ${note.selectedLangMeaning}');
    }
    if (note.userNote != null && note.userNote!.isNotEmpty) {
      buffer.writeln('My Note: ${note.userNote}');
    }
    buffer.writeln('From: ${note.bookTitle} (Page ${note.pageNumber})');

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "${note.word}" meaning to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteNoteWithUndo(
    BuildContext context,
    VocabularyWord note,
    AppState state,
  ) {
    state.deleteVocabularyNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${note.word}" note'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryGold,
          onPressed: () {
            state.addVocabularyNote(note);
          },
        ),
      ),
    );
  }

  void _showEditNoteDialog(
    BuildContext context,
    VocabularyWord note,
    AppState state,
  ) {
    final enController = TextEditingController(text: note.englishMeaning);
    final hiController = TextEditingController(text: note.hindiMeaning);
    final userNoteController = TextEditingController(text: note.userNote ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: AppColors.primaryGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit "${note.word}"',
                  style: const TextStyle(color: Colors.white, fontFamily: 'serif'),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'English Meaning',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: enController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hindi Meaning',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: hiController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Personal Reflection / Note',
                  style: TextStyle(color: AppColors.secondaryAmber, fontSize: 11),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: userNoteController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add personal memory trick or thoughts...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final updated = note.copyWith(
                  englishMeaning: enController.text.trim(),
                  hindiMeaning: hiController.text.trim(),
                  userNote: userNoteController.text.trim(),
                );
                state.updateVocabularyNote(updated);
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated "${note.word}" note'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openFlashcardReview(BuildContext context, List<VocabularyWord> words) {
    if (words.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VocabularyFlashcardsSheet(words: words),
    );
  }
}

// ─── Interactive Flashcards Review Sheet ──────────────────────────────────────

class _VocabularyFlashcardsSheet extends StatefulWidget {
  final List<VocabularyWord> words;

  const _VocabularyFlashcardsSheet({required this.words});

  @override
  State<_VocabularyFlashcardsSheet> createState() => _VocabularyFlashcardsSheetState();
}

class _VocabularyFlashcardsSheetState extends State<_VocabularyFlashcardsSheet> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.words[_currentIndex];
    final total = widget.words.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vocabulary Flashcards',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${word.bookTitle} • Card ${_currentIndex + 1} of $total',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.darkBorder, height: 1),

          // Main Flip Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.darkCardElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isFlipped ? AppColors.primaryGold : AppColors.darkBorder,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isFlipped) ...[
                        // FRONT SIDE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Page ${word.pageNumber} • ${word.cefrLevel}',
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          word.word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (word.pronunciation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            word.pronunciation,
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 16,
                              fontFamily: 'monospace',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.touch_app, size: 14, color: AppColors.textMuted),
                            SizedBox(width: 6),
                            Text(
                              'Tap card to reveal definition',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ] else ...[
                        // BACK SIDE (Definitions)
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          word.englishMeaning,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (word.hindiMeaning.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🇮🇳 ${word.hindiWord} - ${word.hindiMeaning}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textWarmParchment,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (word.exampleSentence.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            word.exampleSentence,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.touch_app, size: 14, color: AppColors.textMuted),
                            SizedBox(width: 6),
                            Text(
                              'Tap to flip back',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation Bar (Previous, Next)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCardElevated,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _currentIndex > 0
                      ? () {
                          setState(() {
                            _currentIndex--;
                            _isFlipped = false;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Prev'),
                ),
                Text(
                  '${_currentIndex + 1} / $total',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _currentIndex < total - 1
                      ? () {
                          setState(() {
                            _currentIndex++;
                            _isFlipped = false;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
