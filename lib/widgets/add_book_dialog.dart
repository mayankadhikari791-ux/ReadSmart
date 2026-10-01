import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Modal dialog allowing users to add a new physical book to their library.
class AddBookDialog extends StatefulWidget {
  final AppState appState;

  const AddBookDialog({super.key, required this.appState});

  static Future<Book?> show(BuildContext context, AppState appState) {
    return showDialog<Book>(
      context: context,
      builder: (ctx) => AddBookDialog(appState: appState),
    );
  }

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final totalPages = int.parse(_pagesController.text.trim());
      final currentPage = int.tryParse(_currentController.text.trim()) ?? 0;

      final newBook = await widget.appState.addPhysicalBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        totalPages: totalPages,
        currentPage: currentPage,
      );

      if (mounted) {
        Navigator.pop(context, newBook);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add book: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      title: Row(
        children: const [
          Icon(Icons.menu_book, color: Color(0xFFD97706), size: 22),
          SizedBox(width: 10),
          Text(
            'Add Physical Book',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: _inputDecoration('Book Title', 'e.g., Dune'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: _inputDecoration('Author', 'e.g., Frank Herbert'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textWhite),
                      decoration: _inputDecoration('Total Pages', '412'),
                      validator: (val) {
                        final p = int.tryParse(val ?? '');
                        if (p == null || p <= 0) return 'Valid pages needed';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _currentController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textWhite),
                      decoration: _inputDecoration('Current Page', '0'),
                      validator: (val) {
                        final cur = int.tryParse(val ?? '0');
                        final tot = int.tryParse(_pagesController.text);
                        if (cur == null || cur < 0) return 'Invalid page';
                        if (tot != null && cur > tot) return 'Exceeds total';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Add to Library', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryGold),
      ),
    );
  }
}

