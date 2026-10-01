// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => '正在加载您的书库...';

  @override
  String get navHome => '首页';

  @override
  String get navLibrary => '书库';

  @override
  String get navStats => '统计';

  @override
  String get navNotes => '笔记';

  @override
  String get navProfile => '我的';

  @override
  String get btnSave => '保存';

  @override
  String get btnCancel => '取消';

  @override
  String get btnClose => '关闭';

  @override
  String get btnEdit => '编辑';

  @override
  String get btnDelete => '删除';

  @override
  String get btnCopy => '复制';

  @override
  String get btnSearch => '搜索';

  @override
  String get btnDone => '完成';

  @override
  String get btnAdd => '添加';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => '继续阅读';

  @override
  String get dashboardQuickStats => '快捷统计';

  @override
  String get dashboardReadingActivity => '阅读动态';

  @override
  String get dashboardAICoach => 'AI阅读教练';

  @override
  String get dashboardRecentBooks => '最近添加';

  @override
  String get libraryTitle => '电子书库';

  @override
  String get libraryAddBook => '添加书籍';

  @override
  String get libraryOpenPdf => '打开PDF';

  @override
  String get libraryAllBooks => '全部';

  @override
  String get libraryReading => '在读';

  @override
  String get libraryCompleted => '已读完';

  @override
  String get libraryUnread => '未读';

  @override
  String get libraryNoBooksFound => '未找到书籍';

  @override
  String get libraryAddFirstBook => '添加您的第一本书开始阅读';

  @override
  String get fullLibraryTitle => '我的书库';

  @override
  String get statsTitle => '阅读统计';

  @override
  String get statsStreak => '连续阅读天数';

  @override
  String get statsPagesRead => '阅读页数';

  @override
  String get statsAvgSession => '平均时长';

  @override
  String get statsBooksCompleted => '已读书籍';

  @override
  String get statsReadingScore => '阅读评分';

  @override
  String get statsWeeklyActivity => '每周动态';

  @override
  String get notesTitle => '生词笔记';

  @override
  String get notesSearchHint => '搜索生词、释义...';

  @override
  String get notesNoNotes => '暂无保存的生词笔记。';

  @override
  String get notesNoNotesHint => '在阅读电子书时轻按单词即可保存笔记！';

  @override
  String get notesFlashcards => '生词卡片';

  @override
  String get notesOpenPage => '前往该页';

  @override
  String get notesEditNote => '编辑笔记';

  @override
  String get notesDeleteConfirm => '笔记已删除';

  @override
  String get notesUndoDelete => '撤销';

  @override
  String get notesAllBooks => '全部书籍';

  @override
  String notesWords(int count) {
    return '$count 个词';
  }

  @override
  String get profileTitle => '个人与设置';

  @override
  String get profileSettings => '设置';

  @override
  String get profileLanguage => '语言';

  @override
  String get profileReadingGoals => '阅读目标';

  @override
  String get profileTheme => '阅读主题';

  @override
  String get profileEditProfile => '编辑个人资料';

  @override
  String get trackerTitle => '阅读计时器';

  @override
  String get trackerStart => '开始计时';

  @override
  String get trackerPause => '暂停';

  @override
  String get trackerResume => '继续';

  @override
  String get trackerFinish => '结束本次阅读';

  @override
  String get trackerSessions => '阅读记录';

  @override
  String get trackerNoSessions => '暂无阅读记录';

  @override
  String get trackerAddBook => '添加纸质书';

  @override
  String readerPage(int current, int total) {
    return '第 $current / $total 页';
  }

  @override
  String get readerNextPage => '下一页';

  @override
  String get readerPrevPage => '上一页';

  @override
  String get readerBookmark => '书签';

  @override
  String get readerZoom => '缩放';

  @override
  String get readerDarkMode => '深色模式';

  @override
  String get readerSepiaMode => '羊皮纸模式';

  @override
  String get readerLightMode => '浅色模式';

  @override
  String get readerLoadingPdf => '正在加载PDF…';

  @override
  String get readerBackToLibrary => '返回书库';

  @override
  String get dictTitle => '词典';

  @override
  String get dictLoading => '查询中...';

  @override
  String get dictNoResult => '未找到释义';

  @override
  String get dictNetworkError => '网络未连接';

  @override
  String get dictEnglishMeaning => '英文释义';

  @override
  String get dictHindiMeaning => '印地语释义';

  @override
  String get dictPronounce => '发音';

  @override
  String get dictSaveToNotes => '保存至笔记';

  @override
  String get dictSearchAgain => '重新搜索';

  @override
  String get dictCopy => '复制';

  @override
  String get dictSavedSuccess => '已保存到笔记！';

  @override
  String get dictCopiedSuccess => '已复制到剪贴板';

  @override
  String get settingsTitle => '语言设置';

  @override
  String get settingsInterfaceLang => '界面语言';

  @override
  String get settingsInterfaceLangSubtitle => '设置所有菜单、标签和按钮的显示语言。';

  @override
  String get settingsDictLang => '词典语言';

  @override
  String get settingsDictLangSubtitle => '单词查询将翻译为这些语言。';

  @override
  String get settingsRegionalLang => '印度区域语言';

  @override
  String get settingsRegionalLangSubtitle => '选择用于补充词汇的区域语言。';

  @override
  String get settingsDualDict => '双语查询';

  @override
  String get settingsDualDictSubtitle => '显示印地语或区域语言的补充翻译';

  @override
  String get settingsSaveBtn => '保存语言设置';

  @override
  String get settingsSavedSuccess => '语言设置已保存！';

  @override
  String get settingsExtensibilityNote => 'ReadSmart 采用可扩展的国际化架构。';

  @override
  String get settingsPrimaryDict => '主要词典';

  @override
  String get settingsSecondaryTranslation => '次要翻译';

  @override
  String get coachTitle => 'AI 教练';

  @override
  String get coachNextTip => '下一条建议';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSepia => '护眼';
}
