import * as admin from "firebase-admin";
import { onUserCreate } from "./auth/onUserCreate";
import { syncBookProgress } from "./books/syncBookProgress";
import { computeReadingStats } from "./stats/computeReadingStats";
import { getReadingTips } from "./coach/getReadingTips";
import { lookupWord } from "./dictionary/lookupWord";

// Initialize Firebase Admin SDK (once, globally)
admin.initializeApp();

// ─── Auth Triggers ──────────────────────────────────────────────────────────
export { onUserCreate };

// ─── Callable Functions ──────────────────────────────────────────────────────
export { syncBookProgress };
export { getReadingTips };
export { lookupWord };

// ─── Firestore Triggers ──────────────────────────────────────────────────────
export { computeReadingStats };

