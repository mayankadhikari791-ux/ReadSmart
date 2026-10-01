import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageNavigationDialog extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  const PageNavigationDialog({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageSelected,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PageNavigationDialog(
        currentPage: currentPage,
        totalPages: totalPages,
        onPageSelected: onPageSelected,
      ),
    );
  }

  @override
  State<PageNavigationDialog> createState() => _PageNavigationDialogState();
}

class _PageNavigationDialogState extends State<PageNavigationDialog> {
  late TextEditingController _controller;
  late int _sliderPage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPage.toString());
    _sliderPage = widget.currentPage;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPage(int page) {
    final clamped = page.clamp(1, widget.totalPages);
    widget.onPageSelected(clamped);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Jump to Page or Chapter',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Number Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Page Number',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      hintText: '1 - ${widget.totalPages}',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryGold),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) _submitPage(parsed);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final parsed = int.tryParse(_controller.text);
                    if (parsed != null) _submitPage(parsed);
                  },
                  child: const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Visual Quick Scrubber Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page $_sliderPage of ${widget.totalPages}',
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                ),
                Text(
                  '${((_sliderPage / widget.totalPages) * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: AppColors.primaryGold,
                inactiveTrackColor: Colors.white12,
                thumbColor: AppColors.primaryGold,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                min: 1,
                max: widget.totalPages.toDouble(),
                value: _sliderPage.toDouble().clamp(1.0, widget.totalPages.toDouble()),
                onChanged: (v) {
                  setState(() {
                    _sliderPage = v.round();
                    _controller.text = _sliderPage.toString();
                  });
                },
                onChangeEnd: (v) => _submitPage(v.round()),
              ),
            ),

            const SizedBox(height: 10),

            // Quick Milestone Jump Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildQuickChip('Start (P. 1)', 1),
                if (widget.totalPages >= 4)
                  _buildQuickChip('25% (P. ${(widget.totalPages * 0.25).round()})',
                      (widget.totalPages * 0.25).round()),
                if (widget.totalPages >= 2)
                  _buildQuickChip('Halfway (P. ${(widget.totalPages * 0.5).round()})',
                      (widget.totalPages * 0.5).round()),
                if (widget.totalPages >= 4)
                  _buildQuickChip('75% (P. ${(widget.totalPages * 0.75).round()})',
                      (widget.totalPages * 0.75).round()),
                _buildQuickChip('End (P. ${widget.totalPages})', widget.totalPages),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, int page) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: const BorderSide(color: Colors.white12),
      onPressed: () => _submitPage(page),
    );
  }
}

