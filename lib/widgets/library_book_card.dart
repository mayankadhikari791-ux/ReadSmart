import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'book_cover_widget.dart';
import 'progress_bar_widget.dart';

/// Modern, versatile book card for ReadSmart Library.
/// Supports both Grid (vertical) and List (horizontal) display modes.
/// Highlights: Cover, Title, Author, Reading progress, Last opened time,
/// Book type badge, Reading status badge, and comprehensive quick actions.
class LibraryBookCard extends StatelessWidget {
  final Book book;
  final bool isGrid;
  final VoidCallback onOpen;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleCompleted;
  final VoidCallback onToggleWantToRead;
  final VoidCallback onDelete;

  const LibraryBookCard({
    super.key,
    required this.book,
    this.isGrid = false,
    required this.onOpen,
    required this.onViewDetails,
    required this.onToggleCompleted,
    required this.onToggleWantToRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridCard(context) : _buildListCard(context);
  }

  // ── List Layout (Horizontal) ───────────────────────────────────────────────
  Widget _buildListCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.darkBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppRadius.roundedLg,
          splashColor: AppColors.primaryGold.withValues(alpha: 0.08),
          highlightColor: AppColors.primaryGold.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Cover
              Stack(
                children: [
                  BookCoverWidget(
                    book: book,
                    width: 76,
                    height: 110,
                  ),
                  if (book.isWantToRead)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.purpleAccent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row (Type & Status)
                    Row(
                      children: [
                        _buildFormatBadge(book),
                        const SizedBox(width: 6),
                        _buildStatusBadge(book),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Author
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress Bar
                    ProgressBarWidget(
                      progress: book.progressPercentage,
                      height: 5,
                      gradientColors: book.isCompleted
                          ? const [AppColors.successGreen, Color(0xFF059669)]
                          : const [AppColors.primaryGold, AppColors.brightFlame],
                      trackColor: AppColors.darkBorder,
                    ),
                    const SizedBox(height: 4),

                    // Meta: Progress % + Last Opened
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${book.progressPercentInt}% • ${book.currentPage}/${book.totalPages}p',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              book.formattedLastOpened,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              _buildMoreMenu(context),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ── Grid Layout (Vertical) ─────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.darkBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppRadius.roundedLg,
          splashColor: AppColors.primaryGold.withValues(alpha: 0.08),
          highlightColor: AppColors.primaryGold.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Cover preview with badges
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: book.coverGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Format Badge Top Left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildFormatBadge(book, compact: true),
                  ),

                  // More Menu Top Right
                  Positioned(
                    top: 2,
                    right: 2,
                    child: _buildMoreMenu(context, isCompact: true),
                  ),
                ],
              ),
            ),

            // Bottom metadata container
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(book, compact: true),
                  const SizedBox(height: 6),
                  ProgressBarWidget(
                    progress: book.progressPercentage,
                    height: 4,
                    gradientColors: book.isCompleted
                        ? const [AppColors.successGreen, Color(0xFF059669)]
                        : const [AppColors.primaryGold, AppColors.brightFlame],
                    trackColor: AppColors.darkBorder,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.progressPercentInt}%',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      Text(
                        book.formattedLastOpened,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Badges ─────────────────────────────────────────────────────────────────
  Widget _buildFormatBadge(Book book, {bool compact = false}) {
    final isPhysical = book.isPhysical;
    final color = isPhysical ? const Color(0xFFD97706) : const Color(0xFF2563EB);
    final icon = isPhysical ? Icons.menu_book : Icons.picture_as_pdf;
    final text = isPhysical ? 'Physical' : 'E-Book';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          if (!compact) const SizedBox(width: 4),
          if (!compact)
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Book book, {bool compact = false}) {
    Color color;
    IconData icon;
    String label;

    switch (book.status) {
      case BookStatus.completed:
        color = AppColors.successGreen;
        icon = Icons.check_circle_outline;
        label = 'Completed';
        break;
      case BookStatus.reading:
        color = AppColors.primaryGold;
        icon = Icons.auto_stories;
        label = 'Reading';
        break;
      case BookStatus.saved:
        color = AppColors.purpleAccent;
        icon = Icons.bookmark_outline;
        label = 'Want to Read';
        break;
      case BookStatus.unread:
        color = AppColors.textMuted;
        icon = Icons.hourglass_empty;
        label = 'Not Started';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 9 : 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 9.5 : 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Overflow Actions Menu ──────────────────────────────────────────────────
  Widget _buildMoreMenu(BuildContext context, {bool isCompact = false}) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: isCompact ? Colors.white70 : AppColors.textMuted,
        size: isCompact ? 18 : 20,
      ),
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      onSelected: (action) {
        switch (action) {
          case 'open':
            onOpen();
            break;
          case 'details':
            onViewDetails();
            break;
          case 'toggle_completed':
            onToggleCompleted();
            break;
          case 'toggle_saved':
            onToggleWantToRead();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'open',
          child: Row(
            children: [
              Icon(
                book.isPhysical ? Icons.timer_outlined : Icons.menu_book,
                size: 16,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 10),
              Text(
                book.isPhysical ? 'Track Reading' : 'Continue Reading',
                style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textWhite),
              const SizedBox(width: 10),
              Text('View Details', style: TextStyle(fontSize: 13, color: AppColors.textWhite)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_saved',
          child: Row(
            children: [
              Icon(
                book.isWantToRead ? Icons.bookmark_remove : Icons.bookmark_add,
                size: 16,
                color: AppColors.purpleAccent,
              ),
              const SizedBox(width: 10),
              Text(
                book.isWantToRead ? 'Remove from Want to Read' : 'Want to Read',
                style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_completed',
          child: Row(
            children: [
              Icon(
                book.isCompleted ? Icons.replay : Icons.check_circle,
                size: 16,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 10),
              Text(
                book.isCompleted ? 'Mark as Reading' : 'Mark Completed',
                style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Delete from Library', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }
}
