// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'ライブラリを読み込み中...';

  @override
  String get navHome => 'ホーム';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navStats => '統計';

  @override
  String get navNotes => 'ノート';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get btnSave => '保存';

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get btnClose => '閉じる';

  @override
  String get btnEdit => '編集';

  @override
  String get btnDelete => '削除';

  @override
  String get btnCopy => 'コピー';

  @override
  String get btnSearch => '検索';

  @override
  String get btnDone => '完了';

  @override
  String get btnAdd => '追加';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => '続きを読む';

  @override
  String get dashboardQuickStats => 'クイック統計';

  @override
  String get dashboardReadingActivity => '読書アクティビティ';

  @override
  String get dashboardAICoach => 'AI読書コーチ';

  @override
  String get dashboardRecentBooks => '最近追加された本';

  @override
  String get libraryTitle => '電子書籍ライブラリ';

  @override
  String get libraryAddBook => '本を追加';

  @override
  String get libraryOpenPdf => 'PDFを開く';

  @override
  String get libraryAllBooks => 'すべて';

  @override
  String get libraryReading => '読書中';

  @override
  String get libraryCompleted => '読了';

  @override
  String get libraryUnread => '未読';

  @override
  String get libraryNoBooksFound => '本が見つかりません';

  @override
  String get libraryAddFirstBook => '最初の本を追加して始めましょう';

  @override
  String get fullLibraryTitle => 'マイライブラリ';

  @override
  String get statsTitle => '読書統計';

  @override
  String get statsStreak => '連続日数';

  @override
  String get statsPagesRead => '読んだページ数';

  @override
  String get statsAvgSession => '平均セッション';

  @override
  String get statsBooksCompleted => '読了した本';

  @override
  String get statsReadingScore => '読書スコア';

  @override
  String get statsWeeklyActivity => '週間アクティビティ';

  @override
  String get notesTitle => '語彙ノート';

  @override
  String get notesSearchHint => '単語や意味を検索...';

  @override
  String get notesNoNotes => '保存された語彙ノートはまだありません。';

  @override
  String get notesNoNotesHint => '電子書籍を読みながら単語をタップしてノートを保存しましょう！';

  @override
  String get notesFlashcards => '単語カード';

  @override
  String get notesOpenPage => 'ページを開く';

  @override
  String get notesEditNote => 'ノートを編集';

  @override
  String get notesDeleteConfirm => 'ノートを削除しました';

  @override
  String get notesUndoDelete => '元に戻す';

  @override
  String get notesAllBooks => 'すべての本';

  @override
  String notesWords(int count) {
    return '$count 単語';
  }

  @override
  String get profileTitle => 'プロフィールと設定';

  @override
  String get profileSettings => '設定';

  @override
  String get profileLanguage => '言語';

  @override
  String get profileReadingGoals => '読書目標';

  @override
  String get profileTheme => '読書テーマ';

  @override
  String get profileEditProfile => 'プロフィールを編集';

  @override
  String get trackerTitle => '読書トラッカー';

  @override
  String get trackerStart => 'セッション開始';

  @override
  String get trackerPause => '一時停止';

  @override
  String get trackerResume => '再開';

  @override
  String get trackerFinish => 'セッション終了';

  @override
  String get trackerSessions => 'セッション履歴';

  @override
  String get trackerNoSessions => 'まだセッションがありません';

  @override
  String get trackerAddBook => '本を追加';

  @override
  String readerPage(int current, int total) {
    return '$current / $total ページ';
  }

  @override
  String get readerNextPage => '次のページ';

  @override
  String get readerPrevPage => '前のページ';

  @override
  String get readerBookmark => 'ブックマーク';

  @override
  String get readerZoom => 'ズーム';

  @override
  String get readerDarkMode => 'ダークモード';

  @override
  String get readerSepiaMode => 'セピアモード';

  @override
  String get readerLightMode => 'ライトモード';

  @override
  String get readerLoadingPdf => 'PDFを読み込み中…';

  @override
  String get readerBackToLibrary => 'ライブラリに戻る';

  @override
  String get dictTitle => '辞書';

  @override
  String get dictLoading => '検索中...';

  @override
  String get dictNoResult => '定義が見つかりません';

  @override
  String get dictNetworkError => 'インターネット接続がありません';

  @override
  String get dictEnglishMeaning => '英語の意味';

  @override
  String get dictHindiMeaning => 'ヒンディー語の意味';

  @override
  String get dictPronounce => '発音';

  @override
  String get dictSaveToNotes => 'ノートに保存';

  @override
  String get dictSearchAgain => '再検索';

  @override
  String get dictCopy => 'コピー';

  @override
  String get dictSavedSuccess => 'ノートに保存しました！';

  @override
  String get dictCopiedSuccess => 'クリップボードにコピーしました';

  @override
  String get settingsTitle => '言語設定';

  @override
  String get settingsInterfaceLang => 'インターフェース言語';

  @override
  String get settingsInterfaceLangSubtitle => 'メニュー、ラベル、ボタンの表示言語を設定します。';

  @override
  String get settingsDictLang => '辞書言語';

  @override
  String get settingsDictLangSubtitle => '単語検索はこれらの言語に翻訳されます。';

  @override
  String get settingsRegionalLang => 'インド地域言語';

  @override
  String get settingsRegionalLangSubtitle => '補足の語彙用の地域言語を選択します。';

  @override
  String get settingsDualDict => '2言語検索';

  @override
  String get settingsDualDictSubtitle => 'ヒンディー語または地域言語での追加の翻訳を表示';

  @override
  String get settingsSaveBtn => '言語設定を保存';

  @override
  String get settingsSavedSuccess => '言語設定が保存されました！';

  @override
  String get settingsExtensibilityNote => 'ReadSmartは拡張可能なローカリゼーション設計を採用しています。';

  @override
  String get settingsPrimaryDict => 'プライマリ辞書';

  @override
  String get settingsSecondaryTranslation => 'セカンダリ翻訳';

  @override
  String get coachTitle => 'AIコーチ';

  @override
  String get coachNextTip => '次のヒント';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeSepia => 'セピア';
}
