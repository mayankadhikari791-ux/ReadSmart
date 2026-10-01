import 'package:flutter/material.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class ReadSmartBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const ReadSmartBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final homeLabel = l10n.navHome;
    final libLabel = l10n.navLibrary;
    final statsLabel = l10n.navStats;
    final notesLabel = l10n.navNotes;
    final profileLabel = l10n.navProfile;

    final navBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, homeLabel),
              _buildNavItem(1, Icons.auto_stories_rounded, libLabel),
              _buildNavItem(2, Icons.insights_rounded, statsLabel),
              _buildNavItem(3, Icons.menu_book_rounded, notesLabel),
              _buildNavItem(4, Icons.person_rounded, profileLabel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final activeColor = AppColors.primaryGold;
    final inactiveColor = AppColors.textMuted;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        label: label,
        button: true,
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: AppRadius.roundedMd,
          splashColor: activeColor.withValues(alpha: 0.1),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: AppRadius.roundedPill,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? activeColor : inactiveColor,
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'sans-serif',
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
