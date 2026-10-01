import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../theme/app_colors.dart';
import 'book_cover_widget.dart';
import 'progress_bar_widget.dart';

/// Modal bottom sheet displaying detailed book statistics, metadata,
/// distinct format descriptions, and reading action controls.
class BookDetailsSheet extends StatelessWidget {
  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onToggleCompleted;
  final VoidCallback onToggleWantToRead;
  final VoidCallback onDelete;

  const BookDetailsSheet({
    super.key,
    required this.book,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onToggleWantToRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Cover & Basic Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCoverWidget(
                  book: book,
                  width: 95,
                  height: 140,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Reviews
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primaryGold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${book.formattedLastOpened}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Format & Status Badges
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildPill(
                            icon: book.isPhysical ? Icons.menu_book : Icons.picture_as_pdf,
                            label: book.formattedBookType,
                            color: book.isPhysical
                                ? const Color(0xFFD97706)
                                : const Color(0xFF2563EB),
                          ),
                          _buildPill(
                            icon: book.isCompleted
                                ? Icons.check_circle_outline
                                : (book.isReading
                                    ? Icons.auto_stories
                                    : (book.isWantToRead
                                        ? Icons.bookmark_outline
                                        : Icons.hourglass_empty)),
                            label: book.formattedStatus,
                            color: book.isCompleted
                                ? AppColors.successGreen
                                : (book.isReading
                                    ? AppColors.primaryGold
                                    : (book.isWantToRead
                                        ? AppColors.purpleAccent
                                        : AppColors.textMuted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Reading Progress Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reading Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${book.progressPercentInt}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: book.isCompleted
                              ? AppColors.successGreen
                              : AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProgressBarWidget(
                    progress: book.progressPercentage,
                    height: 6,
                    gradientColors: book.isCompleted
                        ? const [AppColors.successGreen, Color(0xFF059669)]
                        : const [AppColors.primaryGold, AppColors.brightFlame],
                    trackColor: AppColors.darkBorder,
                  ),
                  const SizedBox(height: 14),

                  // 4 Progress Stats
                  Row(
                    children: [
                      _buildMetricItem(
                        label: 'Current Page',
                        value: '${book.currentPage} / ${book.totalPages}',
                      ),
                      _buildMetricItem(
                        label: 'Remaining',
                        value: '${book.remainingPages} pages',
                      ),
                      _buildMetricItem(
                        label: 'Est. Completion',
                        value: book.estimatedDaysRemaining,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tracking System Distinct Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (book.isPhysical
                        ? const Color(0xFFD97706)
                        : const Color(0xFF2563EB))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (book.isPhysical
                          ? const Color(0xFFD97706)
                          : const Color(0xFF2563EB))
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    book.isPhysical ? Icons.timer_outlined : Icons.chrome_reader_mode,
                    color: book.isPhysical
                        ? const Color(0xFFD97706)
                        : const Color(0xFF38BDF8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      book.isPhysical
                          ? 'Physical Tracker: logs stopwatch time, pages-per-hour pace, and session notes.'
                          : 'E-Book Reader: reads real PDF pages with custom margins, paper warmth, and dictionary.',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textWhite),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Action: Open / Continue Reading
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onOpen();
              },
              icon: Icon(
                book.isPhysical ? Icons.play_arrow : Icons.menu_book,
                size: 18,
              ),
              label: Text(
                book.isPhysical
                    ? 'Track Physical Reading Session'
                    : 'Continue Reading (Page ${book.currentPage > 0 ? book.currentPage : 1})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onToggleWantToRead();
                    },
                    icon: Icon(
                      book.isWantToRead ? Icons.bookmark_remove : Icons.bookmark_add,
                      size: 16,
                      color: AppColors.purpleAccent,
                    ),
                    label: Text(
                      book.isWantToRead ? 'In Want to Read' : 'Want to Read',
                      style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onToggleCompleted();
                    },
                    icon: Icon(
                      book.isCompleted ? Icons.replay : Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.successGreen,
                    ),
                    label: Text(
                      book.isCompleted ? 'Mark Reading' : 'Mark Completed',
                      style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Delete Action
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              label: const Text(
                'Delete from Library',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Delete Book?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${book.title}" from your library?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

