import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/book_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/library_book_card.dart';
import '../widgets/book_details_sheet.dart';
import '../widgets/add_book_dialog.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/progress_bar_widget.dart';
import 'pdf_reader_screen.dart';
import 'physical_tracker_screen.dart';
import 'reader_screen.dart';

enum LibrarySortOption {
  recentlyOpened,
  titleAZ,
  authorAZ,
  progressHighLow,
  highestRating,
  totalPages,
}

/// The Complete ReadSmart Library screen.
/// Features 6 dedicated reading sections (Currently Reading, Want to Read, Completed,
/// Uploaded E-books, Physical Books, Recently Opened) plus unified All view.
/// Supports real-time search, multi-criteria sorting, grid/list toggle,
/// distinct e-book vs physical book tracking routing, and rich book cards.
class FullLibraryScreen extends StatefulWidget {
  final AppState appState;

  const FullLibraryScreen({super.key, required this.appState});

  @override
  State<FullLibraryScreen> createState() => _FullLibraryScreenState();
}

class _FullLibraryScreenState extends State<FullLibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _searchQuery = '';
  bool _isGridView = false;
  LibrarySortOption _sortOption = LibrarySortOption.recentlyOpened;

  static const List<String> _tabNames = [
    'All Books',
    'Currently Reading',
    'Want to Read',
    'Completed',
    'Uploaded E-Books',
    'Physical Books',
    'Recently Opened',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabNames.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Open / Continue Reading Flow (Distinct Routing) ─────────────────────────
  void _openBook(Book book) {
    widget.appState.touchBookOpened(book.id);

    if (book.isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfReaderScreen(
            book: book,
            appState: widget.appState,
            initialPage: book.currentPage > 0 ? book.currentPage : 1,
          ),
        ),
      );
    } else if (book.isPhysical) {
      // Physical Book tracking system
      widget.appState.setSessionBook(book.id, book.title);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhysicalTrackerScreen(appState: widget.appState),
        ),
      );
    } else {
      // Digital E-Book Reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            book: book,
            appState: widget.appState,
            initialPage: book.currentPage > 0 ? book.currentPage : 1,
          ),
        ),
      );
    }
  }

  void _showBookDetails(Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookDetailsSheet(
        book: book,
        onOpen: () => _openBook(book),
        onToggleCompleted: () => widget.appState.markBookStatus(
          book.id,
          book.isCompleted ? BookStatus.reading : BookStatus.completed,
        ),
        onToggleWantToRead: () => widget.appState.toggleBookWantToRead(book.id),
        onDelete: () => widget.appState.deleteBook(book.id),
      ),
    );
  }

  Future<void> _uploadPdfEbook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final newBook = await widget.appState.addPdfBook(filePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${newBook.title}" to library'),
              backgroundColor: AppColors.darkCard,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _addPhysicalBook() async {
    final newBook = await AddBookDialog.show(context, widget.appState);
    if (newBook != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${newBook.title}" to library'),
          backgroundColor: AppColors.darkCard,
        ),
      );
    }
  }

  void _showAddBookMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Book to Library',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Color(0xFF38BDF8)),
              ),
              title: const Text(
                'Upload E-Book (PDF)',
                style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Import a PDF file from your device into the e-reader',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _uploadPdfEbook();
              },
            ),
            const Divider(color: AppColors.darkBorder),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book, color: Color(0xFFD97706)),
              ),
              title: const Text(
                'Add Physical Book',
                style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Track sessions, stopwatch pace, and page counts for paper books',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _addPhysicalBook();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sort Books By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 10),
            _buildSortTile('Recently Opened', LibrarySortOption.recentlyOpened, Icons.access_time),
            _buildSortTile('Title (A – Z)', LibrarySortOption.titleAZ, Icons.sort_by_alpha),
            _buildSortTile('Author (A – Z)', LibrarySortOption.authorAZ, Icons.person_outline),
            _buildSortTile('Reading Progress (% High to Low)', LibrarySortOption.progressHighLow, Icons.trending_up),
            _buildSortTile('Highest Rating', LibrarySortOption.highestRating, Icons.star_outline),
            _buildSortTile('Total Pages (Longest First)', LibrarySortOption.totalPages, Icons.format_list_numbered),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(String title, LibrarySortOption option, IconData icon) {
    final isSelected = _sortOption == option;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryGold : AppColors.textMuted),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryGold : AppColors.textWhite,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primaryGold, size: 18)
          : null,
      onTap: () {
        setState(() => _sortOption = option);
        Navigator.pop(context);
      },
    );
  }

  // ── Filter & Sort Pipelines ────────────────────────────────────────────────
  List<Book> _getFilteredAndSorted(List<Book> source) {
    var result = source;

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q))
          .toList();
    }

    // Sorting
    final sorted = List<Book>.from(result);
    switch (_sortOption) {
      case LibrarySortOption.recentlyOpened:
        sorted.sort((a, b) {
          final aTime = a.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        break;
      case LibrarySortOption.titleAZ:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case LibrarySortOption.authorAZ:
        sorted.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
        break;
      case LibrarySortOption.progressHighLow:
        sorted.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
        break;
      case LibrarySortOption.highestRating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case LibrarySortOption.totalPages:
        sorted.sort((a, b) => b.totalPages.compareTo(a.totalPages));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search title or author...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _isSearchActive = false;
                      });
                    },
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                 l10n.fullLibraryTitle,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (!_isSearchActive)
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.primaryGold),
              onPressed: () => setState(() => _isSearchActive = true),
            ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.textWhite,
            ),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.primaryGold),
            tooltip: 'Sort Books',
            onPressed: _showSortOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'All (${state.books.length})'),
            Tab(text: 'Reading (${state.currentlyReadingBooks.length})'),
            Tab(text: 'Want to Read (${state.wantToReadBooks.length})'),
            Tab(text: 'Completed (${state.completedBooks.length})'),
            Tab(text: 'E-Books (${state.uploadedEbooks.length})'),
            Tab(text: 'Physical (${state.physicalLibraryBooks.length})'),
            Tab(text: 'Recently Opened (${state.recentlyOpenedBooks.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBookMenu,
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Book',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. All Books (Overview + Sections)
          _buildAllView(state),

          // 2. Currently Reading
          _buildBookListView(
            state.currentlyReadingBooks,
            emptyTitle: 'No active reading books',
            emptySubtitle: 'Start reading an e-book or track a physical book to see it here.',
            icon: Icons.auto_stories,
          ),

          // 3. Want to Read
          _buildBookListView(
            state.wantToReadBooks,
            emptyTitle: 'No books in Want to Read',
            emptySubtitle: 'Bookmark books or save them to your reading wishlist.',
            icon: Icons.bookmark_border,
          ),

          // 4. Completed
          _buildBookListView(
            state.completedBooks,
            emptyTitle: 'No completed books yet',
            emptySubtitle: 'Mark books completed as you reach the final page.',
            icon: Icons.check_circle_outline,
          ),

          // 5. Uploaded E-books
          _buildBookListView(
            state.uploadedEbooks,
            emptyTitle: 'No uploaded e-books',
            emptySubtitle: 'Import a PDF document to read with physical book layout & dictionary.',
            icon: Icons.picture_as_pdf,
            actionLabel: 'Upload PDF',
            onAction: _uploadPdfEbook,
          ),

          // 6. Physical Books
          _buildBookListView(
            state.physicalLibraryBooks,
            emptyTitle: 'No physical books tracked',
            emptySubtitle: 'Add paper books to log reading sessions, stopwatch time, and PPH.',
            icon: Icons.menu_book,
            actionLabel: 'Add Physical Book',
            onAction: _addPhysicalBook,
          ),

          // 7. Recently Opened
          _buildBookListView(
            state.recentlyOpenedBooks,
            emptyTitle: 'No recently opened books',
            emptySubtitle: 'Your most recently read books will appear here automatically.',
            icon: Icons.access_time,
          ),
        ],
      ),
    );
  }

  // ── Unified All View ───────────────────────────────────────────────────────
  Widget _buildAllView(AppState state) {
    final allBooks = _getFilteredAndSorted(state.books);

    // If searching, show standard filtered grid/list
    if (_searchQuery.trim().isNotEmpty) {
      return _buildBookGridOrList(allBooks);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // 1. Stats Counter Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildMetricChip(
                icon: Icons.library_books,
                count: state.books.length.toString(),
                label: 'Total Books',
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                icon: Icons.auto_stories,
                count: state.currentlyReadingBooks.length.toString(),
                label: 'Reading',
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                icon: Icons.check_circle,
                count: state.completedBooks.length.toString(),
                label: 'Completed',
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                icon: Icons.bookmark,
                count: state.wantToReadBooks.length.toString(),
                label: 'Wishlist',
                color: AppColors.purpleAccent,
              ),
            ],
          ),
        ),

        // 2. Section: Recently Opened (Quick Resume Carousel)
        if (state.recentlyOpenedBooks.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Recently Opened',
            actionText: 'View All',
            onTap: () => _tabController.animateTo(6),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: state.recentlyOpenedBooks.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final book = state.recentlyOpenedBooks[i];
                return _buildRecentResumeCard(book);
              },
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 3. Section: Currently Reading
        if (state.currentlyReadingBooks.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Currently Reading',
            actionText: 'View All',
            onTap: () => _tabController.animateTo(1),
          ),
          for (final book in state.currentlyReadingBooks.take(3))
            LibraryBookCard(
              book: book,
              isGrid: false,
              onOpen: () => _openBook(book),
              onViewDetails: () => _showBookDetails(book),
              onToggleCompleted: () => widget.appState.markBookStatus(
                book.id,
                book.isCompleted ? BookStatus.reading : BookStatus.completed,
              ),
              onToggleWantToRead: () => widget.appState.toggleBookWantToRead(book.id),
              onDelete: () => widget.appState.deleteBook(book.id),
            ),
          const SizedBox(height: 18),
        ],

        // 4. Section: Want to Read
        if (state.wantToReadBooks.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Want to Read',
            actionText: 'View All',
            onTap: () => _tabController.animateTo(2),
          ),
          for (final book in state.wantToReadBooks.take(3))
            LibraryBookCard(
              book: book,
              isGrid: false,
              onOpen: () => _openBook(book),
              onViewDetails: () => _showBookDetails(book),
              onToggleCompleted: () => widget.appState.markBookStatus(
                book.id,
                book.isCompleted ? BookStatus.reading : BookStatus.completed,
              ),
              onToggleWantToRead: () => widget.appState.toggleBookWantToRead(book.id),
              onDelete: () => widget.appState.deleteBook(book.id),
            ),
          const SizedBox(height: 18),
        ],

        // 5. Section: Uploaded E-Books & Physical Books Highlights
        _buildSectionHeader(
          title: 'Formats Overview',
          actionText: 'See E-Books',
          onTap: () => _tabController.animateTo(4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildFormatCard(
                  title: 'Uploaded E-Books',
                  subtitle: '${state.uploadedEbooks.length} documents',
                  icon: Icons.picture_as_pdf,
                  color: const Color(0xFF2563EB),
                  onTap: () => _tabController.animateTo(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormatCard(
                  title: 'Physical Books',
                  subtitle: '${state.physicalLibraryBooks.length} titles',
                  icon: Icons.menu_book,
                  color: const Color(0xFFD97706),
                  onTap: () => _tabController.animateTo(5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab View Helper (Filtering, Sorting, Empty states) ─────────────────────
  Widget _buildBookListView(
    List<Book> sourceList, {
    required String emptyTitle,
    required String emptySubtitle,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final books = _getFilteredAndSorted(sourceList);

    if (books.isEmpty) {
      return EmptyStateWidget(
        icon: icon,
        title: emptyTitle,
        message: emptySubtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      );
    }

    return _buildBookGridOrList(books);
  }

  Widget _buildBookGridOrList(List<Book> books) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: books.length,
        itemBuilder: (ctx, i) {
          final book = books[i];
          return LibraryBookCard(
            book: book,
            isGrid: true,
            onOpen: () => _openBook(book),
            onViewDetails: () => _showBookDetails(book),
            onToggleCompleted: () => widget.appState.markBookStatus(
              book.id,
              book.isCompleted ? BookStatus.reading : BookStatus.completed,
            ),
            onToggleWantToRead: () => widget.appState.toggleBookWantToRead(book.id),
            onDelete: () => widget.appState.deleteBook(book.id),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: books.length,
      itemBuilder: (ctx, i) {
        final book = books[i];
        return LibraryBookCard(
          book: book,
          isGrid: false,
          onOpen: () => _openBook(book),
          onViewDetails: () => _showBookDetails(book),
          onToggleCompleted: () => widget.appState.markBookStatus(
            book.id,
            book.isCompleted ? BookStatus.reading : BookStatus.completed,
          ),
          onToggleWantToRead: () => widget.appState.toggleBookWantToRead(book.id),
          onDelete: () => widget.appState.deleteBook(book.id),
        );
      },
    );
  }

  // ── Supporting UI Elements ─────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResumeCard(Book book) {
    return InkWell(
      onTap: () => _openBook(book),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 125,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: BookCoverWidget(
                book: book,
                width: 75,
                height: 98,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            ProgressBarWidget(
              progress: book.progressPercentage,
              height: 3.5,
              gradientColors: book.isCompleted
                  ? const [AppColors.successGreen, Color(0xFF059669)]
                  : const [AppColors.primaryGold, AppColors.brightFlame],
              trackColor: AppColors.darkBorder,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${book.progressPercentInt}%',
                  style: const TextStyle(fontSize: 10, color: AppColors.textWhite),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    book.formattedLastOpened,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
