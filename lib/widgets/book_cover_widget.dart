import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../theme/app_colors.dart';

class BookCoverWidget extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final bool showBadge;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.width = 65,
    this.height = 90,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: book.coverGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Texture lines
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          // Book Title initials / emblem
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: width * 0.28,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (width * 0.12).clamp(8.0, 11.0),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status Badge
          if (showBadge)
            Positioned(
              top: 4,
              left: 4,
              child: _buildStatusBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color bgColor;
    Color textColor;

    switch (book.status) {
      case BookStatus.reading:
        text = 'READING';
        bgColor = AppColors.primaryGold;
        textColor = Colors.black;
        break;
      case BookStatus.completed:
        text = 'DONE';
        bgColor = AppColors.successGreen;
        textColor = Colors.white;
        break;
      case BookStatus.saved:
        text = 'SAVED';
        bgColor = AppColors.purpleAccent;
        textColor = Colors.white;
        break;
      case BookStatus.unread:
        text = 'NEW';
        bgColor = AppColors.infoBlue;
        textColor = Colors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
