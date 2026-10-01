import 'dart:io';
import 'dart:typed_data';

/// Result of validating an uploaded/selected PDF file.
class PdfValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String sanitizedTitle;
  final int fileSizeBytes;

  const PdfValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.sanitizedTitle,
    this.fileSizeBytes = 0,
  });

  factory PdfValidationResult.failure(String message) {
    return PdfValidationResult(
      isValid: false,
      errorMessage: message,
      sanitizedTitle: 'Untitled PDF',
    );
  }

  factory PdfValidationResult.success({
    required String sanitizedTitle,
    required int fileSizeBytes,
  }) {
    return PdfValidationResult(
      isValid: true,
      sanitizedTitle: sanitizedTitle,
      fileSizeBytes: fileSizeBytes,
    );
  }
}

/// Security & integrity validator for PDF files.
/// Enforces:
/// 1. File existence and readability
/// 2. File extension (.pdf)
/// 3. File name sanitization (prevents path traversal / illegal characters)
/// 4. File size limits (0 bytes < size <= 100 MB)
/// 5. Magic bytes header inspection (%PDF-)
class PdfValidator {
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB max
  static const List<int> _pdfMagicBytes = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-

  /// Flag for testing environments where synthetic mock paths are used without files on disk.
  static bool bypassDiskCheckForTesting = false;

  /// Sanitizes a file title, stripping traversal patterns and illegal characters.
  static String sanitizeTitle(String rawFileName) {
    var name = rawFileName.split(RegExp(r'[/\\]')).last;
    if (name.toLowerCase().endsWith('.pdf')) {
      name = name.substring(0, name.length - 4);
    }
    // Remove directory traversal characters & control characters
    name = name.replaceAll(RegExp(r'[\x00-\x1F\x7F<>:"/\\|?*]'), '');
    name = name.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.length > 100) {
      name = name.substring(0, 100).trim();
    }
    return name.isNotEmpty ? name : 'Untitled Document';
  }

  /// Validates a PDF file at [filePath] synchronously or asynchronously.
  static Future<PdfValidationResult> validate(String filePath) async {
    final trimmedPath = filePath.trim();
    if (trimmedPath.isEmpty) {
      return PdfValidationResult.failure('No file path provided.');
    }

    if (bypassDiskCheckForTesting) {
      final lowerPath = trimmedPath.toLowerCase();
      if (!lowerPath.endsWith('.pdf')) {
        return PdfValidationResult.failure('Invalid file type: file must be a .pdf document.');
      }
      return PdfValidationResult.success(
        sanitizedTitle: sanitizeTitle(trimmedPath),
        fileSizeBytes: 1024,
      );
    }

    final file = File(trimmedPath);

    // 1. File existence
    if (!await file.exists()) {
      return PdfValidationResult.failure('The selected file does not exist on disk.');
    }

    // 2. Extension check
    final lowerPath = trimmedPath.toLowerCase();
    if (!lowerPath.endsWith('.pdf')) {
      return PdfValidationResult.failure('Invalid file type: file must be a .pdf document.');
    }

    // 3. File size check
    int size = 0;
    try {
      size = await file.length();
    } catch (e) {
      return PdfValidationResult.failure('Unable to inspect file size: $e');
    }

    if (size == 0) {
      return PdfValidationResult.failure('The selected PDF file is empty (0 bytes).');
    }

    if (size > maxFileSizeBytes) {
      final sizeMb = (size / (1024 * 1024)).toStringAsFixed(1);
      return PdfValidationResult.failure(
        'PDF exceeds maximum allowed size (100 MB). Selected file is $sizeMb MB.',
      );
    }

    // 4. Inspect magic bytes header (%PDF-)
    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      final header = await raf.read(5);
      if (header.length < 5 || !_matchesMagicBytes(header)) {
        return PdfValidationResult.failure(
          'Corrupted or invalid document: file does not have a valid PDF header (%PDF-).',
        );
      }
    } catch (e) {
      return PdfValidationResult.failure('Could not verify PDF file integrity: $e');
    } finally {
      try {
        await raf?.close();
      } catch (_) {}
    }

    final title = sanitizeTitle(trimmedPath);
    return PdfValidationResult.success(
      sanitizedTitle: title,
      fileSizeBytes: size,
    );
  }

  static bool _matchesMagicBytes(Uint8List bytes) {
    for (int i = 0; i < _pdfMagicBytes.length; i++) {
      if (bytes[i] != _pdfMagicBytes[i]) return false;
    }
    return true;
  }
}
