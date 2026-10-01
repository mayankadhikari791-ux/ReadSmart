class VocabularyWord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String word;
  final String pronunciation;
  final String englishMeaning;
  final String hindiMeaning;
  final String hindiWord;
  final String exampleSentence;
  final String dateSaved;
  final String cefrLevel;
  final int pageNumber;
  final String? selectedLangMeaning;
  final String? selectedLangCode;
  final String? userNote;
  final DateTime? savedAt;

  VocabularyWord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.word,
    required this.pronunciation,
    required this.englishMeaning,
    required this.hindiMeaning,
    required this.hindiWord,
    required this.exampleSentence,
    required this.dateSaved,
    this.cefrLevel = 'CEFR B2',
    this.pageNumber = 1,
    this.selectedLangMeaning,
    this.selectedLangCode,
    this.userNote,
    this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'word': word,
      'pronunciation': pronunciation,
      'englishMeaning': englishMeaning,
      'hindiMeaning': hindiMeaning,
      'hindiWord': hindiWord,
      'exampleSentence': exampleSentence,
      'dateSaved': dateSaved,
      'cefrLevel': cefrLevel,
      'pageNumber': pageNumber,
      'selectedLangMeaning': selectedLangMeaning,
      'selectedLangCode': selectedLangCode,
      'userNote': userNote,
      'savedAt': savedAt?.toIso8601String(),
    };
  }

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String? ?? '',
      englishMeaning: json['englishMeaning'] as String? ?? '',
      hindiMeaning: json['hindiMeaning'] as String? ?? '',
      hindiWord: json['hindiWord'] as String? ?? '',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      dateSaved: json['dateSaved'] as String? ?? 'Recently',
      cefrLevel: json['cefrLevel'] as String? ?? 'CEFR B2',
      pageNumber: json['pageNumber'] as int? ?? 1,
      selectedLangMeaning: json['selectedLangMeaning'] as String?,
      selectedLangCode: json['selectedLangCode'] as String?,
      userNote: json['userNote'] as String?,
      savedAt: json['savedAt'] != null
          ? DateTime.tryParse(json['savedAt'] as String)
          : null,
    );
  }

  VocabularyWord copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? word,
    String? pronunciation,
    String? englishMeaning,
    String? hindiMeaning,
    String? hindiWord,
    String? exampleSentence,
    String? dateSaved,
    String? cefrLevel,
    int? pageNumber,
    String? selectedLangMeaning,
    String? selectedLangCode,
    String? userNote,
    DateTime? savedAt,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      word: word ?? this.word,
      pronunciation: pronunciation ?? this.pronunciation,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      hindiMeaning: hindiMeaning ?? this.hindiMeaning,
      hindiWord: hindiWord ?? this.hindiWord,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      dateSaved: dateSaved ?? this.dateSaved,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedLangMeaning: selectedLangMeaning ?? this.selectedLangMeaning,
      selectedLangCode: selectedLangCode ?? this.selectedLangCode,
      userNote: userNote ?? this.userNote,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
