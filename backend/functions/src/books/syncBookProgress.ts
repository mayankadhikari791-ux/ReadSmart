import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface SyncProgressData {
  bookId: string;
  currentPage: number;
  totalPages: number;
  durationSeconds: number;
  pagesRead: number;
  readingSpeedWpm: number;
}

/**
 * Callable: Sync reading progress for a book and log a session.
 * Called from the Flutter app when the reader closes or a physical session ends.
 */
export const syncBookProgress = onCall<SyncProgressData>(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be signed in.");
    }

    const uid = request.auth.uid;
    const { bookId, currentPage, totalPages, durationSeconds, pagesRead, readingSpeedWpm } =
      request.data;

    // Validate input
    if (!bookId || typeof currentPage !== "number" || currentPage < 0) {
      throw new HttpsError("invalid-argument", "Invalid bookId or currentPage.");
    }

    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();

    // Update book's current page
    batch.set(
      db.doc(`users/${uid}/books/${bookId}`),
      { currentPage, lastReadAt: now },
      { merge: true }
    );

    // Update reading progress
    const progressPercentage = totalPages > 0 ? currentPage / totalPages : 0;
    batch.set(db.doc(`users/${uid}/progress/${bookId}`), {
      bookId,
      currentPage,
      totalPages,
      progressPercentage,
      lastReadTimestamp: now,
    });

    // Log the reading session (only if meaningful)
    if (durationSeconds > 0 && pagesRead > 0) {
      const sessionRef = db.collection(`users/${uid}/sessions`).doc();
      batch.set(sessionRef, {
        id: sessionRef.id,
        bookId,
        durationSeconds,
        pagesRead,
        readingSpeedWpm,
        timestamp: now,
      });
    }

    await batch.commit();

    return { success: true, syncedAt: new Date().toISOString() };
  }
);

