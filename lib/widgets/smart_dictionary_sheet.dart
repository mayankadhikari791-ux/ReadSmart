import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../models/dictionary_entry_model.dart';
import '../models/vocabulary_word_model.dart';
import '../services/dictionary/i_dictionary_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Smart Dictionary Modal Sheet
///
/// Displays rich, real-time dictionary definitions, pronunciation, Hindi and
/// multilingual meanings, parts of speech, and contextual examples.
///
/// Allows saving directly to the book's vocabulary notes, copying definitions,
/// and searching again directly from the sheet.
class SmartDictionarySheet extends StatefulWidget {
  final String word;
  final String bookTitle;
  final int pageNumber;
  final AppState appState;
  final String? bookId;
  final IDictionaryService? dictionaryService;

  const SmartDictionarySheet({
    super.key,
    required this.word,
    required this.bookTitle,
    required this.pageNumber,
    required this.appState,
    this.bookId,
    this.dictionaryService,
  });

  static Future<void> show(
    BuildContext context, {
    required String word,
    required String bookTitle,
    required int pageNumber,
    required AppState appState,
    String? bookId,
    IDictionaryService? dictionaryService,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SmartDictionarySheet(
        word: word,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        appState: appState,
        bookId: bookId,
        dictionaryService: dictionaryService,
      ),
    );
  }

  @override
  State<SmartDictionarySheet> createState() => _SmartDictionarySheetState();
}

class _SmartDictionarySheetState extends State<SmartDictionarySheet> {
  late final IDictionaryService _service;
  late final TextEditingController _searchController;

  late String _currentWord;
  String _selectedLang = 'HI';
  String? _selectedPartOfSpeech;
  bool _isSaved = false;
  bool _isLoading = true;
  DictionaryResult? _result;
  bool _isSearchingNewWord = false;

  @override
  void initState() {
    super.initState();
    _service = widget.dictionaryService ?? widget.appState.dictionaryService;
    _currentWord = widget.word;
    _searchController = TextEditingController(text: _currentWord);

    // Initialize selected target language code from AppState preference
    final prefLang = widget.appState.localeCode.isNotEmpty
        ? widget.appState.localeCode.toUpperCase()
        : 'HI';
    _selectedLang = prefLang;

    _lookupWord(_currentWord);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _lookupWord(String query) async {
    setState(() {
      _currentWord = query;
      _isLoading = true;
      _isSearchingNewWord = false;
    });

    final targetLangCode = _selectedLang.toLowerCase();
    final result = await _service.lookupWord(
      query,
      targetLanguage: targetLangCode,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _result = result;
      if (result.isSuccess && result.entry != null) {
        _selectedPartOfSpeech = result.entry!.primaryPartOfSpeech;
      }
      _checkIfAlreadySaved();
    });
  }

  void _checkIfAlreadySaved() {
    final word = _currentWord.toLowerCase().trim();
    final existing = widget.appState
        .notesForBook(widget.bookTitle)
        .any((n) => n.word.toLowerCase().trim() == word);
    _isSaved = existing;
  }

  void _handleSaveNote() {
    final entry = _result?.entry;
    if (entry == null) return;

    final resolvedBookId = widget.bookId ??
        widget.appState.books
            .firstWhere(
              (b) =>
                  b.title.trim().toLowerCase() ==
                  widget.bookTitle.trim().toLowerCase(),
              orElse: () => widget.appState.currentlyReadingBook,
            )
            .id;

    final note = VocabularyWord(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      bookId: resolvedBookId,
      bookTitle: widget.bookTitle,
      word: entry.word,
      pronunciation: entry.phonetic ?? '/${entry.word.toLowerCase()}/',
      englishMeaning: entry.primaryDefinition,
      hindiMeaning: entry.hindiMeaning ?? 'अर्थ उपलब्ध नहीं है',
      hindiWord: entry.hindiWord ?? entry.word,
      exampleSentence: entry.primaryExample ??
          'Read in "${widget.bookTitle}" (Page ${widget.pageNumber})',
      dateSaved: 'Just now',
      pageNumber: widget.pageNumber,
      selectedLangMeaning: entry.targetLangMeaning,
      selectedLangCode: entry.targetLangCode,
      savedAt: DateTime.now(),
    );

    widget.appState.addVocabularyNote(note);
    setState(() => _isSaved = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Saved "${entry.word}" to ${widget.bookTitle} Notes!',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleCopyDefinition() {
    final entry = _result?.entry;
    if (entry == null) return;

    final buffer = StringBuffer();
    buffer.writeln('${entry.word} ${entry.phonetic ?? ""}');
    buffer.writeln('English: ${entry.primaryDefinition}');
    if (entry.hindiMeaning != null) {
      buffer.writeln('Hindi: ${entry.hindiWord ?? ""} - ${entry.hindiMeaning}');
    }
    if (entry.targetLangMeaning != null) {
      buffer.writeln(
          '${entry.targetLangCode.toUpperCase()}: ${entry.targetLangMeaning}');
    }
    if (entry.primaryExample != null) {
      buffer.writeln('Example: "${entry.primaryExample}"');
    }
    buffer.writeln('From: ${widget.bookTitle} (Page ${widget.pageNumber})');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: const [
            Icon(Icons.copy_rounded, color: AppColors.primaryGold, size: 18),
            SizedBox(width: 8),
            Text('Copied definition to clipboard!'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePronounce() {
    final entry = _result?.entry;
    final word = entry?.word ?? _currentWord;
    _service.pronounce(word, audioUrl: entry?.audioUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCardElevated,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: AppColors.primaryGold, size: 18),
            const SizedBox(width: 8),
            Text('Pronouncing "$word"'),
          ],
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sheet Header with Book Association
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: AppColors.primaryGold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Dictionary',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Text(
                            'From "${widget.bookTitle}" • Page ${widget.pageNumber}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Search Again toggle button
                    IconButton(
                      icon: Icon(
                        _isSearchingNewWord ? Icons.search_off : Icons.search,
                        color: _isSearchingNewWord
                            ? AppColors.primaryGold
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchingNewWord = !_isSearchingNewWord;
                        });
                      },
                      tooltip: 'Search another word',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search Bar (shown when toggled)
              if (_isSearchingNewWord)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter word to look up...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: AppColors.darkCard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.darkBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.primaryGold),
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              _lookupWord(val.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _lookupWord(_searchController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Lookup'),
                      ),
                    ],
                  ),
                ),

              const Divider(color: AppColors.darkBorder, height: 20),

              // Dynamic Body Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildBodyContent(),
              ),

              const SizedBox(height: 16),

              // Action Buttons Row: Save to Notes, Pronounce, Copy, Close
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    // Save to Notes
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: _isSaved ? null : _handleSaveNote,
                        icon: Icon(
                          _isSaved ? Icons.check : Icons.bookmark_add,
                          size: 18,
                        ),
                        label: Text(_isSaved
                            ? (AppLocalizations.of(context).btnDone)
                            : (AppLocalizations.of(context).dictSaveToNotes)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaved
                              ? Colors.grey.shade800
                              : AppColors.primaryGold,
                          foregroundColor:
                              _isSaved ? Colors.white70 : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Pronounce
                    IconButton.outlined(
                      onPressed: _handlePronounce,
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      color: AppColors.primaryGold,
                      tooltip: AppLocalizations.of(context).dictPronounce,
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Copy
                    IconButton.outlined(
                      onPressed: _handleCopyDefinition,
                      icon: const Icon(Icons.copy_rounded, size: 19),
                      color: AppColors.textWhite,
                      tooltip: AppLocalizations.of(context).dictCopy,
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close
                    IconButton.outlined(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 19),
                      color: AppColors.textMuted,
                      tooltip: AppLocalizations.of(context).btnClose,
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
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

  Widget _buildBodyContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_result == null || _result!.hasError) {
      return _buildErrorState(_result);
    }

    final entry = _result!.entry!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word Title & Phonetic
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                entry.word,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            if (entry.phonetic != null && entry.phonetic!.isNotEmpty)
              Text(
                entry.phonetic!,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'monospace',
                ),
              ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _handlePronounce,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.volume_up,
                    color: AppColors.primaryGold, size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Parts of Speech Filter Tabs (e.g. noun, verb, adjective)
        if (entry.allPartsOfSpeech.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: entry.allPartsOfSpeech.map((pos) {
                final isSelected =
                    (_selectedPartOfSpeech ?? entry.primaryPartOfSpeech)
                            .toLowerCase() ==
                        pos.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(pos.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedPartOfSpeech = pos);
                    },
                    selectedColor: AppColors.primaryGold,
                    backgroundColor: AppColors.darkCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // English Definition Card
        _buildEnglishDefinitionCard(entry),

        const SizedBox(height: 12),

        // Multilingual / Hindi Translation Card
        _buildTranslationCard(entry),

        // Synonyms Section (if available)
        if (entry.allSynonyms.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSynonymsSection(entry.allSynonyms),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Looking up "$_currentWord"…',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Retrieving definitions, phonetics, and translations',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(DictionaryResult? result) {
    final isNetwork = result?.isNetworkError == true;
    final isNotFound = result?.isNotFound == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNetwork
                ? AppColors.dangerRed.withValues(alpha: 0.4)
                : AppColors.primaryGold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetwork
                  ? Icons.wifi_off_rounded
                  : (isNotFound
                      ? Icons.search_off_rounded
                      : Icons.info_outline_rounded),
              size: 48,
              color: isNetwork ? AppColors.dangerRed : AppColors.primaryGold,
            ),
            const SizedBox(height: 12),
            Text(
              isNetwork
                  ? 'Connection Issue'
                  : (isNotFound ? 'Word Not Found' : 'Lookup Notice'),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result?.errorMessage ?? 'Unable to retrieve definition.',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (result?.suggestions.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Did you mean:',
                style: TextStyle(color: AppColors.textWhite, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: result!.suggestions.map((s) {
                  return ActionChip(
                    label: Text(s),
                    backgroundColor: AppColors.darkSurface,
                    labelStyle: const TextStyle(
                        color: AppColors.primaryGold, fontSize: 12),
                    onPressed: () => _lookupWord(s),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _lookupWord(_currentWord),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnglishDefinitionCard(DictionaryEntry entry) {
    final activePos = _selectedPartOfSpeech ?? entry.primaryPartOfSpeech;
    final definitions = entry.definitionsForPartOfSpeech(activePos);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ENGLISH DEFINITION',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activePos,
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Render numbered definitions if multiple, or single definition
          ...definitions.take(3).map((def) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (definitions.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0, top: 2.0),
                      child: Text(
                        '•',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          def.definition,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14.5,
                            height: 1.45,
                            fontFamily: 'serif',
                          ),
                        ),
                        if (def.example != null && def.example!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '“${def.example}”',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(DictionaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TRANSLATION / हिंदी अनुवाद',
                  style: TextStyle(
                    color: AppColors.secondaryAmber,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Language toggle pills
              Row(
                children: [
                  _buildLangChip('HI', '🇮🇳 HI'),
                  const SizedBox(width: 4),
                  _buildLangChip('ES', '🇪🇸 ES'),
                  const SizedBox(width: 4),
                  _buildLangChip('FR', '🇫🇷 FR'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Always display Hindi Meaning as required by Step 5
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    '🇮🇳 HINDI MEANING / अर्थ:',
                    style: TextStyle(
                      color: AppColors.secondaryAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (entry.hindiWord != null && entry.hindiWord!.isNotEmpty)
                Text(
                  entry.hindiWord!,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                entry.hindiMeaning ?? 'अर्थ उपलब्ध नहीं है',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),

          // 2. If user selected a language other than Hindi, show it below as required by Step 6
          if (_selectedLang != 'HI' && _selectedLang != 'EN') ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.darkBorder, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '🌐 $_selectedLang TRANSLATION:',
                  style: const TextStyle(
                    color: AppColors.infoBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              entry.targetLangWord ?? entry.word,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.targetLangMeaning ?? 'Translation loading...',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSynonymsSection(List<String> synonyms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synonyms',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: synonyms.take(8).map((syn) {
            return InkWell(
              onTap: () => _lookupWord(syn),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Text(
                  syn,
                  style: const TextStyle(
                    color: AppColors.textWarmParchment,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLang == code;
    return InkWell(
      onTap: () {
        setState(() => _selectedLang = code);
        // Refresh with target language translation if needed
        _lookupWord(_currentWord);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
