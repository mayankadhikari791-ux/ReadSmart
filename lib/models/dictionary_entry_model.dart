/// Domain models for the Smart Dictionary feature in ReadSmart.
///
/// Designed to encapsulate multi-definition, multi-part-of-speech dictionary
/// entries, multilingual translations (e.g. Hindi, Spanish, French),
/// phonetics, audio pronunciations, and error handling states.

enum DictionaryStatus {
  success,
  notFound,
  networkError,
  error,
}

class DefinitionItem {
  final String definition;
  final String? example;
  final List<String> synonyms;

  const DefinitionItem({
    required this.definition,
    this.example,
    this.synonyms = const [],
  });

  factory DefinitionItem.fromJson(Map<String, dynamic> json) {
    final syns = (json['synonyms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    return DefinitionItem(
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String?,
      synonyms: syns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      if (example != null) 'example': example,
      'synonyms': synonyms,
    };
  }
}

class WordMeaning {
  final String partOfSpeech;
  final List<DefinitionItem> definitions;
  final List<String> synonyms;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms = const [],
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    final defs = (json['definitions'] as List<dynamic>?)
            ?.map((d) => DefinitionItem.fromJson(d as Map<String, dynamic>))
            .toList() ??
        const [];
    final syns = (json['synonyms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return WordMeaning(
      partOfSpeech: json['partOfSpeech'] as String? ?? 'general',
      definitions: defs,
      synonyms: syns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definitions': definitions.map((d) => d.toJson()).toList(),
      'synonyms': synonyms,
    };
  }
}

class DictionaryEntry {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final List<WordMeaning> meanings;
  final String? hindiWord;
  final String? hindiMeaning;
  final String? targetLangWord;
  final String? targetLangMeaning;
  final String targetLangCode;
  final List<String> synonyms;
  final String? origin;

  const DictionaryEntry({
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.meanings,
    this.hindiWord,
    this.hindiMeaning,
    this.targetLangWord,
    this.targetLangMeaning,
    this.targetLangCode = 'HI',
    this.synonyms = const [],
    this.origin,
  });

  /// Primary or first definition found
  String get primaryDefinition {
    for (final m in meanings) {
      for (final d in m.definitions) {
        if (d.definition.trim().isNotEmpty) return d.definition.trim();
      }
    }
    return 'Definition not available.';
  }

  /// Primary part of speech (e.g. noun, verb)
  String get primaryPartOfSpeech {
    if (meanings.isNotEmpty) {
      return meanings.first.partOfSpeech;
    }
    return 'noun';
  }

  /// Primary example quote / sentence
  String? get primaryExample {
    for (final m in meanings) {
      for (final d in m.definitions) {
        if (d.example != null && d.example!.trim().isNotEmpty) {
          return d.example!.trim();
        }
      }
    }
    return null;
  }

  /// Distinct list of all parts of speech this word satisfies
  List<String> get allPartsOfSpeech {
    final list = meanings.map((m) => m.partOfSpeech.toLowerCase()).toSet().toList();
    return list.isNotEmpty ? list : const ['general'];
  }

  /// Returns definitions belonging to a specific part of speech
  List<DefinitionItem> definitionsForPartOfSpeech(String pos) {
    final target = pos.toLowerCase();
    final matching = meanings.where((m) => m.partOfSpeech.toLowerCase() == target);
    final defs = <DefinitionItem>[];
    for (final m in matching) {
      defs.addAll(m.definitions);
    }
    return defs.isNotEmpty
        ? defs
        : (meanings.isNotEmpty ? meanings.first.definitions : const []);
  }

  /// Returns aggregated synonyms
  List<String> get allSynonyms {
    final set = <String>{...synonyms};
    for (final m in meanings) {
      set.addAll(m.synonyms);
      for (final d in m.definitions) {
        set.addAll(d.synonyms);
      }
    }
    return set.toList();
  }

  DictionaryEntry copyWith({
    String? hindiWord,
    String? hindiMeaning,
    String? targetLangWord,
    String? targetLangMeaning,
    String? targetLangCode,
  }) {
    return DictionaryEntry(
      word: word,
      phonetic: phonetic,
      audioUrl: audioUrl,
      meanings: meanings,
      hindiWord: hindiWord ?? this.hindiWord,
      hindiMeaning: hindiMeaning ?? this.hindiMeaning,
      targetLangWord: targetLangWord ?? this.targetLangWord,
      targetLangMeaning: targetLangMeaning ?? this.targetLangMeaning,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      synonyms: synonyms,
      origin: origin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      if (phonetic != null) 'phonetic': phonetic,
      if (audioUrl != null) 'audioUrl': audioUrl,
      'meanings': meanings.map((m) => m.toJson()).toList(),
      if (hindiWord != null) 'hindiWord': hindiWord,
      if (hindiMeaning != null) 'hindiMeaning': hindiMeaning,
      if (targetLangWord != null) 'targetLangWord': targetLangWord,
      if (targetLangMeaning != null) 'targetLangMeaning': targetLangMeaning,
      'targetLangCode': targetLangCode,
      'synonyms': synonyms,
      if (origin != null) 'origin': origin,
    };
  }

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final rawMeanings = (json['meanings'] as List<dynamic>?)
            ?.map((m) => WordMeaning.fromJson(m as Map<String, dynamic>))
            .toList() ??
        const [];
    final syns = (json['synonyms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return DictionaryEntry(
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String?,
      audioUrl: json['audioUrl'] as String?,
      meanings: rawMeanings,
      hindiWord: json['hindiWord'] as String?,
      hindiMeaning: json['hindiMeaning'] as String?,
      targetLangWord: json['targetLangWord'] as String?,
      targetLangMeaning: json['targetLangMeaning'] as String?,
      targetLangCode: json['targetLangCode'] as String? ?? 'HI',
      synonyms: syns,
      origin: json['origin'] as String?,
    );
  }
}

class DictionaryResult {
  final DictionaryStatus status;
  final DictionaryEntry? entry;
  final String? errorMessage;
  final List<String> suggestions;

  const DictionaryResult({
    required this.status,
    this.entry,
    this.errorMessage,
    this.suggestions = const [],
  });

  bool get isSuccess => status == DictionaryStatus.success && entry != null;
  DictionaryEntry? get data => entry;
  bool get isNotFound => status == DictionaryStatus.notFound;
  bool get isNetworkError => status == DictionaryStatus.networkError;
  bool get hasError => status != DictionaryStatus.success;

  factory DictionaryResult.success(DictionaryEntry entry) {
    return DictionaryResult(status: DictionaryStatus.success, entry: entry);
  }

  factory DictionaryResult.notFound({String? message, List<String>? suggestions}) {
    return DictionaryResult(
      status: DictionaryStatus.notFound,
      errorMessage: message ?? 'Word not found in dictionary.',
      suggestions: suggestions ?? const [],
    );
  }

  factory DictionaryResult.networkError([String? message]) {
    return DictionaryResult(
      status: DictionaryStatus.networkError,
      errorMessage: message ?? 'Network error. Please check your internet connection.',
    );
  }

  factory DictionaryResult.error(String message) {
    return DictionaryResult(
      status: DictionaryStatus.error,
      errorMessage: message,
    );
  }
}

