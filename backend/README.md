# 🔥 ReadSmart — Firebase Backend

> **Firebase + Cloud Functions backend for ReadSmart**  
> Handles user authentication, cloud sync, AI reading coach, and smart dictionary via Firestore + Cloud Functions.

---

## 🗂️ Project Structure

```
backend/
├── README.md                        # This file
├── .firebaserc                      # Firebase project alias config
├── firebase.json                    # Firebase service configuration
├── firestore.rules                  # Firestore security rules
├── firestore.indexes.json           # Firestore composite indexes
├── storage.rules                    # Firebase Storage security rules
│
└── functions/                       # Cloud Functions (Node.js / Python)
    ├── package.json                 # Node.js dependencies
    ├── tsconfig.json                # TypeScript config (if using TS)
    ├── src/
    │   ├── index.ts                 # Functions entry point (exports all)
    │   ├── auth/
    │   │   └── onUserCreate.ts      # Triggered on new user sign-up
    │   ├── books/
    │   │   └── syncBookProgress.ts  # Sync reading progress across devices
    │   ├── stats/
    │   │   └── computeReadingStats.ts # Aggregate reading statistics
    │   ├── coach/
    │   │   └── getReadingTips.ts    # AI coach: fetch personalized tips via Gemini API
    │   └── dictionary/
    │       └── lookupWord.ts        # Smart dictionary: word lookup + AI explanation
    └── lib/                         # Compiled JS output (auto-generated, gitignored)
```

---

## 🔑 Firebase Services Used

| Service | Purpose |
|---|---|
| **Firebase Auth** | User sign-in (Email/Password, Google Sign-In) |
| **Cloud Firestore** | Primary database — books, sessions, notes, stats |
| **Firebase Storage** | Store e-book files (EPUB/PDF), cover images |
| **Cloud Functions** | Server-side logic, AI integrations, background jobs |
| **Firebase Hosting** | (Optional) Host web version of ReadSmart |

---

## 🗄️ Firestore Data Model

```
users/
  {userId}/
    profile          → UserModel (name, avatar, joined_at, reading_goal)
    settings         → LanguagePreferenceModel, theme
    stats            → ReadingStatisticsModel (aggregated)
    books/
      {bookId}       → BookModel (title, author, cover_url, total_pages, format)
    sessions/
      {sessionId}    → ReadingSessionModel (book_id, start_time, end_time, pages_read, wpm)
    progress/
      {bookId}       → ReadingProgressModel (current_page, percentage, last_read_at)
    notes/
      {noteId}       → BookNoteModel (book_id, page, content, type: highlight|note)
    bookmarks/
      {bookmarkId}   → BookmarkModel (book_id, page, label)
    vocabulary/
      {wordId}       → VocabularyWordModel (word, definition, book_id, page)
    reading_goals/
      {goalId}       → ReadingGoalModel (target_books, target_pages, deadline)
```

---

## ⚡ Cloud Functions

| Function | Trigger | Description |
|---|---|---|
| `onUserCreate` | Auth: onCreate | Creates default user profile & settings doc in Firestore |
| `syncBookProgress` | Callable | Updates `progress/{bookId}` and logs a new session |
| `computeReadingStats` | Firestore: onWrite | Aggregates sessions into `stats` doc when a session is written |
| `getReadingTips` | Callable | Calls Gemini API to generate personalized reading tips for coach screen |
| `lookupWord` | Callable | Smart dictionary: fetches definition + AI explanation for a word |

---

## 🚀 Getting Started

### Prerequisites

- Node.js `>=18`
- Firebase CLI: `npm install -g firebase-tools`
- A Google/Firebase account

### Initial Setup

```bash
# 1. Navigate to the backend folder
cd Book_Reader/backend

# 2. Login to Firebase
firebase login

# 3. Initialize project (if not already done)
firebase init

# Select:
#   ✅ Firestore
#   ✅ Functions
#   ✅ Storage
#   ✅ Hosting (optional)

# 4. Install function dependencies
cd functions
npm install

# 5. Return to backend root
cd ..
```

### Local Development (Emulators)

```bash
# Start all Firebase emulators locally
firebase emulators:start

# Emulator UI available at: http://localhost:4000
# Firestore:  http://localhost:8080
# Functions:  http://localhost:5001
# Auth:       http://localhost:9099
# Storage:    http://localhost:9199
```

### Deploy

```bash
# Deploy everything
firebase deploy

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy only Cloud Functions
firebase deploy --only functions

# Deploy a specific function
firebase deploy --only functions:getReadingTips
```

---

## 🔒 Firestore Security Rules

Key rules to implement in `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🤖 AI Integration (Gemini API)

The **Coach** and **Smart Dictionary** features use the **Gemini API** via Cloud Functions.

```typescript
// functions/src/coach/getReadingTips.ts
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

export const getReadingTips = functions.https.onCall(async (data) => {
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
  // ... generate personalized tips based on user's reading stats
});
```

Set the API key in Firebase environment config:

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

---

## 🔌 Flutter Integration

In the Flutter app, add these packages to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  cloud_functions: ^latest
```

Then initialize Firebase in `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ... rest of initialization
}
```

Replace local repository implementations with Firebase ones:

| Local Implementation | Replace With |
|---|---|
| `local_book_repository.dart` | `firebase_book_repository.dart` |
| `local_session_repository.dart` | `firebase_session_repository.dart` |
| `local_settings_repository.dart` | `firebase_settings_repository.dart` |
| `local_vocabulary_repository.dart` | `firebase_vocabulary_repository.dart` |

All new classes must implement the same interfaces (`i_*.dart`) — no changes needed in `AppState`.

---

## 🌍 Environment Variables

| Variable | Where | Purpose |
|---|---|---|
| `GEMINI_API_KEY` | Firebase Secret | Gemini API for AI coach & dictionary |

---

## 📝 Notes for Developers

- **Never** commit `firebase-debug.log`, `ui-debug.log`, or the `functions/lib/` folder.
- Add `functions/lib/` and `.env` to `.gitignore`.
- Always test locally with emulators before deploying (`firebase emulators:start`).
- Firestore indexes must be defined in `firestore.indexes.json` for complex queries.
- All callable functions should validate `context.auth` before processing requests.
- Keep function code small and single-purpose — one file per function.

---

## 📦 Useful Firebase CLI Commands

```bash
firebase projects:list           # List all your Firebase projects
firebase use <project-id>        # Switch active project
firebase emulators:start         # Run everything locally
firebase deploy                  # Deploy all services
firebase firestore:delete --all-collections  # ⚠️ Wipe Firestore (dev only!)
firebase functions:log           # Stream function logs
```

