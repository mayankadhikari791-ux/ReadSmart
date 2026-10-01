import 'package:flutter/material.dart';
import '../models/bookmark_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class BookmarksSheet extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final int currentPage;
  final AppState appState;
  final ValueChanged<int> onPageSelected;

  const BookmarksSheet({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.currentPage,
    required this.appState,
    required this.onPageSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String bookId,
    required String bookTitle,
    required int currentPage,
    required AppState appState,
    required ValueChanged<int> onPageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BookmarksSheet(
        bookId: bookId,
        bookTitle: bookTitle,
        currentPage: currentPage,
        appState: appState,
        onPageSelected: onPageSelected,
      ),
    );
  }

  @override
  State<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<BookmarksSheet> {
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final list = await widget.appState.getBookmarksForBook(widget.bookId);
    if (mounted) {
      setState(() {
        _bookmarks = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCurrentPageBookmark() async {
    await widget.appState.saveBookmark(
      bookId: widget.bookId,
      page: widget.currentPage,
      title: 'Page ${widget.currentPage} — ${widget.bookTitle}',
    );
    await _loadBookmarks();
  }

  Future<void> _deleteBookmark(String id) async {
    await widget.appState.deleteBookmark(id);
    await _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bookmarks_rounded,
                        color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Bookmarks (${_bookmarks.length})',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.bookmark_add_rounded,
                      color: AppColors.primaryGold, size: 16),
                  label: Text('Save P. ${widget.currentPage}',
                      style: const TextStyle(
                          color: AppColors.primaryGold, fontSize: 12)),
                  onPressed: _addCurrentPageBookmark,
                ),
              ],
            ),
            const Divider(color: AppColors.darkBorder, height: 16),

            // Bookmarks List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                ),
              )
            else if (_bookmarks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.bookmark_border_rounded,
                          size: 48, color: AppColors.textMuted),
                      SizedBox(height: 10),
                      Text(
                        'No bookmarks saved for this book yet.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Save P. X" above or the bookmark icon while reading.',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _bookmarks.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final b = _bookmarks[index];
                    final isCurrent = b.pageNumber == widget.currentPage;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryGold
                              : AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'P. ${b.pageNumber}',
                          style: TextStyle(
                            color: isCurrent ? Colors.black : AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      title: Text(
                        b.title.isNotEmpty
                            ? b.title
                            : 'Page ${b.pageNumber}',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white38, size: 18),
                        onPressed: () => _deleteBookmark(b.id),
                      ),
                      onTap: () {
                        widget.onPageSelected(b.pageNumber);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

