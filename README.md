# 📚 ReadSmart — Smart Reading Companion & E-Reader Application

> A modern, feature-rich Flutter application for tracking physical & digital reading habits, reading real PDF e-books, building vocabulary with a smart dictionary, and boosting reading comprehension through transparent analytics.

---

## 🚦 Project Phases & Roadmap

| Phase | Description | Status | Key Highlights |
|---|---|---|---|
| **Phase 1** | App Architecture & Design Tokens | ✅ **Completed** | Stitch design tokens, Dark/Light/Sepia themes, Clean AppState |
| **Phase 2** | Dashboard, Stats & Analytics | ✅ **Completed** | WPM speed chart, consistency score, streak tracker |
| **Phase 3** | Physical Book Reading Tracker | ✅ **Completed** | Stopwatch, PPH calculation, session notes, insights dialog |
| **Phase 4** | E-Book Library & Management | ✅ **Completed** | Shelf management, filter tabs, grid/list toggle |
| **Phase 5** | Smart PDF E-Book Reader | ✅ **Completed** | Cross-platform PDF page rendering (`pdfx`), native file picker (`file_picker`), reading timer, auto-bookmarking, last-page persistence, zoom, brightness overlay, distraction-free reading |
| **Phase 6** | Smart Dictionary Feature | ✅ **Completed** | Clean `IDictionaryService` abstraction, live Free Dictionary API + MyMemory translation (Hindi + target languages), audio/speech pronunciation, copy, save to notes with `bookId`, multiple parts of speech, non-blocking UI |
| **Phase 7** | Vocabulary Notes & Flashcards | ✅ **Completed** | Book-scoped vocabulary isolation (`BookVocabularyCollection`), tabbed All/per-book notes, live search, page-filter bar, edit/delete with undo, flashcard review (flip-card), "Open Page X" navigation back to reader, full Hindi + target-language meanings stored |
| **Phase 8** | Internationalization & Multilingual UI | ✅ **Completed** | Flutter i18n (`gen_l10n` + `.arb`), English & Hindi fully localized, extensible architecture with Spanish, French, German, Japanese, Chinese, and Arabic (RTL) ready, live locale switching in Settings, dictionary language logically decoupled from UI language |
| **Phase 9** | Reading Analytics & Intelligent Improvement System | ✅ **Completed** | Cross-format tracking (physical + e-book), Daily/Weekly/Monthly duration breakdowns, Books started/completed, Consistency matrix, Dynamic PPH/WPM pace calculations, Interactive time/pages activity chart, Remaining completion estimates, Intelligent suggestions with comprehension-first guardrails |
| **Phase 10** | Personalized Reading Coach & Goals System | ✅ **Completed** | Historical behavior analysis across 8 metrics, 7 targeted practical recommendation areas, 5 simple tracked reading goals with live progress, 30-sec comprehension self-assessment dialog, strict retention guardrails, Home Dashboard integration |
| **Phase 11** | Physical Book Feel E-Reader Upgrade | ✅ **Completed** | Book-like margins & physical spine crease shadow, comfortable typography & line spacing presets, Warm paper/sepia, dark & light themes, animated page transitions, tap zones navigation (25%/50%/25%), auto-hiding distraction-free controls, dedicated Reader Settings bottom sheet, visual page navigation dialog with milestone chips, bookmarks drawer with one-tap jump |
| **Phase 12** | Complete ReadSmart Library | ✅ **Completed** | 7-tab library (Currently Reading, Want to Read, Completed, E-books, Physical, Recent), premium `LibraryBookCard` (grid/list), `BookDetailsSheet` with full stats, `AddBookDialog`, live search + sort + filter, distinct e-book/physical routing, `touchBookOpened`, `markBookStatus`, `toggleBookWantToRead` |
| **Phase 13** | Profile, Goals & Settings Suite | ✅ **Completed** | Full Profile & Settings: live avatar/user edit (`EditProfileSheet`), reading goals customization (`ReadingGoalsSheet`), Reader & Appearance preferences, separate App/Dictionary language routing, reading statistics summary, notification toggles, vocabulary export (.json), and safe reading history clearing with `ConfirmActionDialog` (protects books & notes) |
| **Phase 14** | Production Backend Integration Architecture | ✅ **Completed** | Full Decoupled Service Architecture across 10 areas, `Resource<T>` loading/success/error/offline state management, `NetworkFailure` hierarchy (timeout, unauthorized, server, invalid data), `IAuthService` & `MockAuthService`, `ApiClient` with secrets management (`AppConfig`), `OfflineFirstBookRepository` with zero-latency offline reading, `NetworkStatusBanner`, `AsyncStateBuilder` |
| **Phase 15** | Real Dictionary & Translation Service Integration | ✅ **Completed** | Cache-first L1+L2 `DictionaryCacheManager`, `FreeDictionaryService` with MyMemory translation (Hindi always + selected language), HTTP 429 rate-limit backoff, offline fallback dictionary, word detection via `SelectableText` context menu in reader, `ProxyDictionaryService` for secret-safe backend routing, `AppConfig` secrets management, 73 tests passing across 9 suites |
| **Phase 16** | Professional UI/UX Commercial Polish Pass | ✅ **Completed** | Comprehensive design system tokens (`AppSpacing`, `AppRadius`, `AppTypography`, `AppShadows`), theme system overhaul (dialogs, sheets, snackbars, smooth transitions), primary e-book reader decluttering (Apple Books / Kindle-grade minimal top bar, precision scrubber, essential 4-tool dock, serene loading view), `EmptyStateWidget`, adaptive bottom navigation with accessibility semantics, polished card elevations |
| **Phase 17** | Complete Functional Testing & Stabilization | ✅ **Completed** | 144/144 tests passing across 10 suites, 0 analyzer errors/warnings, critical vocabulary isolation verified (same word across different books = two permanently separated records), all overflow guards, deprecated API migrations, and offline continuity validated |
| **Phase 18** | Cloud Sync & Firebase Backend | 📋 **Planned** | Live Firebase Firestore sync, Cloud Functions, and remote cloud backup |

---

## 🗂️ Project Structure

```
Book_Reader/
├── lib/
│   ├── main.dart                        # App entry point, theme setup
│   ├── screens/                         # All UI screens
│   │   ├── main_shell.dart              # Bottom-nav shell (5 tabs)
│   │   ├── home_dashboard_screen.dart   # Dashboard with reading stats
│   │   ├── reader_screen.dart           # Mock interactive text reader
│   │   ├── pdf_reader_screen.dart       # Real PDF reader with pdfx & controls
│   │   ├── ebook_library_screen.dart    # Digital library & PDF file picker
│   │   ├── full_library_screen.dart     # Full library browser
│   │   ├── stats_screen.dart            # Reading analytics & charts
│   │   ├── notes_screen.dart            # Book-scoped vocabulary notes
│   │   ├── physical_tracker_screen.dart # Physical reading tracker & session logs
│   │   ├── coach_screen.dart            # AI reading coach & comprehension tips
│   │   ├── profile_screen.dart          # User profile & reading goals
│   │   └── language_settings_screen.dart# Language & translation settings
│   ├── models/                          # Data models
│   │   ├── book_model.dart              # Book entity (supports filePath for PDFs)
│   │   ├── bookmark_model.dart          # Page bookmark model
│   │   ├── reading_session_model.dart   # Reading session model
│   │   ├── reading_statistics_model.dart# Aggregate statistics model
│   │   ├── reading_goal_model.dart      # Reading goal metrics
│   │   ├── reading_tip_model.dart       # Coaching tips model
│   │   ├── language_preference_model.dart# Target language model
│   │   ├── vocabulary_word_model.dart   # Vocabulary note model
│   │   ├── dictionary_entry_model.dart  # Dictionary entry model (Phase 6)
│   │   ├── reading_analytics_models.dart# Analytics breakdowns, charts & insights (Phase 9)
│   │   ├── coach_models.dart            # Recommendations, goals & comprehension logs (Phase 10)
│   │   └── reader_settings_model.dart   # Physical book typography, margins & transitions (Phase 11)
│   ├── core/                            # Core infrastructure & configuration
│   │   ├── config/                      # Environment variables & secret handling
│   │   │   └── app_config.dart          # Production AppConfig (--dart-define)
│   │   └── network/                     # Network abstractions & state modeling
│   │       ├── network_exceptions.dart  # Typed NetworkFailure hierarchy
│   │       └── resource.dart            # Resource<T> loading/success/error/offline
│   ├── services/                        # Service abstractions
│   │   ├── api/                         # Resilient HTTP Client
│   │   │   └── api_client.dart          # Robust ApiClient with timeout & error mapping
│   │   ├── auth/                        # Authentication services
│   │   │   ├── i_auth_service.dart      # Decoupled IAuthService interface
│   │   │   └── mock_auth_service.dart   # Mock/Offline auth service implementation
│   │   ├── pdf_session_service.dart     # Lightweight timer service for PDF reader
│   │   └── dictionary/                  # Dictionary services (Phase 6 + Phase 15)
│   │       ├── i_dictionary_service.dart      # Clean service interface
│   │       ├── free_dictionary_service.dart   # Free Dict API + MyMemory (cache-first)
│   │       ├── proxy_dictionary_service.dart  # Secure backend proxy (Phase 15)
│   │       └── dictionary_cache_manager.dart  # L1 memory + L2 persistent cache (Phase 15)
│   ├── state/
│   │   └── app_state.dart               # Central ChangeNotifier state & coach engine
│   ├── data/
│   │   ├── database_manager.dart        # Data layer coordinator
│   │   ├── repositories/                # Repository interfaces & implementations
│   │   │   ├── i_book_repository.dart
│   │   │   ├── i_session_repository.dart
│   │   │   ├── i_settings_repository.dart
│   │   │   ├── i_vocabulary_repository.dart
│   │   │   ├── sync/
│   │   │   │   └── offline_first_book_repository.dart # Offline-first cached book repo
│   │   │   ├── local/                   # Local JSON storage repositories
│   │   │   └── firebase/                # Cloud Firestore repositories
│   │   └── storage/
│   │       └── local_json_storage_driver.dart
│   ├── widgets/                         # Reusable UI components
│   │   ├── network_status_banner.dart   # Offline/Sync/Error status banner (Phase 14)
│   │   ├── async_state_builder.dart     # Standardized loading/error/success builder (Phase 14)
│   │   ├── book_cover_widget.dart
│   │   ├── bottom_nav_bar.dart
│   │   ├── progress_bar_widget.dart
│   │   ├── reading_speed_chart.dart     # WPM speed chart
│   │   ├── analytics_time_chart.dart    # Reading time & daily pages bar chart (Phase 9)
│   │   ├── reading_consistency_chart.dart# 14-day reading consistency habit matrix (Phase 9)
│   │   ├── intelligent_insights_card.dart# Diagnostic improvement & guardrail cards (Phase 9)
│   │   ├── coach_goal_card.dart         # Daily reading goals progress card (Phase 10)
│   │   ├── comprehension_check_dialog.dart# 30-sec retention self-assessment (Phase 10)
│   │   ├── smart_dictionary_sheet.dart  # Modal bottom sheet for word definitions
│   │   ├── pdf_reader_controls.dart     # Bottom controls overlay for PDF reader
│   │   ├── reader_settings_sheet.dart   # Dedicated e-reader typography & comfort panel (Phase 11)
│   │   ├── page_navigation_dialog.dart  # Numeric scrubber & milestone jump dialog (Phase 11)
│   │   ├── bookmarks_sheet.dart         # One-tap jump & bookmark drawer (Phase 11)
│   │   ├── library_book_card.dart       # Premium grid/list book card with badges & progress (Phase 12)
│   │   ├── book_details_sheet.dart      # Deep book detail sheet with stats & actions (Phase 12)
│   │   ├── add_book_dialog.dart         # Modal form for adding physical books (Phase 12)
│   │   ├── confirm_action_dialog.dart   # Reusable confirmation dialog for destructive actions (Phase 13)
│   │   ├── edit_profile_sheet.dart      # Modal bottom sheet for editing user profile (Phase 13)
│   │   ├── reading_goals_sheet.dart     # Modal bottom sheet for customizing reading goals (Phase 13)
│   │   ├── empty_state_widget.dart      # Standardized empty state presentation (Phase 16)
│   │   └── stat_card.dart
│   └── theme/
│       ├── app_colors.dart              # Color design tokens & gradients
│       ├── app_tokens.dart              # Geometric spacing, radius, typography & shadows (Phase 16)
│       └── app_theme.dart               # Light / Dark / Sepia themes with unified component themes
├── test/
│   ├── physical_tracker_test.dart       # Unit & state integration tests
│   ├── dictionary_service_test.dart     # Unit tests for dictionary & translation
│   ├── reading_analytics_test.dart      # Unit & analytics engine tests (Phase 9)
│   ├── reading_coach_test.dart          # Unit & personalized coach engine tests (Phase 10)
│   ├── ebook_reader_test.dart           # E-reader physical book feel & comfort tests (Phase 11)
│   ├── library_management_test.dart     # Library sections, lifecycle & wishlist tests (Phase 12)
│   ├── profile_settings_test.dart       # Profile, goals, export, history safety tests (Phase 13)
│   ├── backend_architecture_test.dart   # Backend decoupling, offline resilience & auth tests (Phase 14)
│   └── smart_dictionary_integration_test.dart  # Cache, translation, rate-limit & JSON serialization tests (Phase 15)
├── .env.example                         # Environment secrets template
└── pubspec.yaml
```

---

## 🔄 Session Resumption & Development Guidelines

> [!TIP]
> **For developers and AI coding agents resuming this project:**
> 1. Run `flutter test` — all 73 tests must pass across all 9 test suites (`test/physical_tracker_test.dart`, `test/dictionary_service_test.dart`, `test/reading_analytics_test.dart`, `test/reading_coach_test.dart`, `test/ebook_reader_test.dart`, `test/library_management_test.dart`, `test/profile_settings_test.dart`, `test/backend_architecture_test.dart`, `test/smart_dictionary_integration_test.dart`).
> 2. Run `dart analyze lib/` — ensure zero compilation errors. (Deprecation warnings about `withOpacity` and `activeColor` are pre-existing and acceptable.)
> 3. Refer to the **Roadmap table above** to determine the current active phase (next: Phase 17 — Cloud Sync & Firebase Backend).
> 4. Keep all file imports consistent:
>    - Models: `import 'package:read_smart/models/...';`
>    - Repositories: relative paths `import '../i_book_repository.dart';`
> 5. **Localization Architecture**:
>    - Configuration: `l10n.yaml` at project root
>    - ARB translation files: `lib/l10n/app_{en,hi,es,fr,de,ja,zh,ar}.arb`
>    - Code generation: `flutter gen-l10n` creates `lib/l10n/app_localizations.dart`
>    - UI Locale vs Dictionary: `AppState.appLocale` powers UI; dictionary translations remain independent via `IDictionaryService` (English + Hindi + target regional language always available)
> 6. **Comprehension-First Absolute Principle**:
>    - Never recommend sacrificing comprehension purely to increase reading speed. The coach prioritizes retention, active recall, and cognitive absorption over superficial pace.
> 7. **Physical Book Feel E-Reader Experience**:
>    - Maintain comfortable typography, paper textures/shading, subtle spine crease shadows, tap zones navigation (25%/50%/25%), and auto-hiding distraction-free reading controls.
> 8. **Dictionary & Secrets Architecture** (Phase 15):
>    - Never hardcode API keys. Use `--dart-define=KEY=value` at build time, read via `AppConfig` using `String.fromEnvironment()`.
>    - `DictionaryCacheManager` provides L1 (memory) + L2 (persistent JSON) caching. HTTP 429 triggers 45-second per-host backoff.
>    - `FreeDictionaryService` uses the Free Dictionary API + MyMemory. `ProxyDictionaryService` routes through a backend proxy when `AppConfig.useDictionaryProxy` is true.
> 9. When finishing any future phase, always update this `README.md` to reflect completed items and document new features.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code / Antigravity IDE
- Connected device, Windows desktop, or emulator

### Installation & Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run tests to verify build health (144 tests across 10 suites — all pass)
flutter test

# 3. Launch application
flutter run
```

---

## 🎨 Reading Themes

Three themes are supported via `ReadingThemeMode` enum in `AppState`:

| Mode | Theme Data | Background | Accent |
|---|---|---|---|
| `dark` | `AppTheme.darkTheme` | `#141414` | `#E8A020` (Gold) |
| `light` | `AppTheme.lightTheme` | `#FAFAFA` | `#E8A020` (Gold) |
| `sepia` | `AppTheme.sepiaTheme` | `#F8F0DC` | `#C47A1A` (Amber) |
