import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/book_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/progress_bar_widget.dart';
import 'reader_screen.dart';
import 'pdf_reader_screen.dart';

class EbookLibraryScreen extends StatefulWidget {
  final AppState appState;

  const EbookLibraryScreen({super.key, required this.appState});

  @override
  State<EbookLibraryScreen> createState() => _EbookLibraryScreenState();
}

class _EbookLibraryScreenState extends State<EbookLibraryScreen> {
  String _selectedFilter = 'All Books';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
           l10n.libraryTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search books feature opened'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: _showAddPdfDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add PDF', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Horizontal Pills)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Books'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Reading'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Saved'),
                ],
              ),
            ),
          ),

          // Sort & View Switcher Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'Sort by: ',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    Text(
                      'Recent ▾',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: _isGridView
                            ? AppColors.primaryGold
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isGridView = true),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_list_rounded,
                        color: !_isGridView
                            ? AppColors.primaryGold
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isGridView = false),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Books View
          Expanded(
            child: books.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView(books)
                    : _buildListView(books),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPdfDialog,
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Book> _filteredBooks() {
    final all = widget.appState.books;
    switch (_selectedFilter) {
      case 'Reading':
        return all.where((b) => b.status == BookStatus.reading).toList();
      case 'Completed':
        return all.where((b) => b.status == BookStatus.completed).toList();
      case 'Saved':
        return all.where((b) => b.status == BookStatus.saved).toList();
      default:
        return all;
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => _openReader(book),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: BookCoverWidget(
                      book: book,
                      width: 105,
                      height: 140,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                ProgressBarWidget(progress: book.progressPercentage, height: 4),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${book.currentPage}/${book.totalPages}p',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 9.5),
                    ),
                    Text(
                      book.lastReadTime,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 9.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => _openReader(book),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                BookCoverWidget(book: book, width: 45, height: 65),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProgressBarWidget(
                          progress: book.progressPercentage, height: 4),
                      const SizedBox(height: 4),
                      Text(
                        'Page ${book.currentPage} of ${book.totalPages} • ${book.progressPercentInt}% • ${book.lastReadTime}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 48, color: Colors.grey.shade700),
          const SizedBox(height: 12),
          const Text(
            'No books in this category',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _openReader(Book book) {
    if (book.isPdf) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              PdfReaderScreen(book: book, appState: widget.appState),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ReaderScreen(book: book, appState: widget.appState),
        ),
      );
    }
  }

  Future<void> _showAddPdfDialog() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return; // user cancelled

      final pickedFile = result.files.first;
      final path = pickedFile.path;

      if (path == null || path.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not access the selected file.'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
        return;
      }

      // Add book to library
      final book = await widget.appState.addPdfBook(path);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.successGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"${book.title}" added to your library!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.darkCard,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Open',
            textColor: AppColors.primaryGold,
            onPressed: () => _openReader(book),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import PDF: ${e.toString()}'),
          backgroundColor: AppColors.dangerRed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
