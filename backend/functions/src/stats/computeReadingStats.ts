import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

/**
 * Firestore Trigger: Recomputes reading statistics when a session is written.
 * Listens to: users/{userId}/sessions/{sessionId}
 */
export const computeReadingStats = onDocumentWritten(
  {
    document: "users/{userId}/sessions/{sessionId}",
    region: "asia-south1",
  },
  async (event) => {
    const userId = event.params.userId;
    const db = admin.firestore();

    // Fetch all sessions for this user
    const sessionsSnap = await db
      .collection(`users/${userId}/sessions`)
      .orderBy("timestamp", "desc")
      .get();

    if (sessionsSnap.empty) return;

    const sessions = sessionsSnap.docs.map((d) => d.data());

    // ─── Aggregate stats ────────────────────────────────────────────────
    const totalPagesRead = sessions.reduce((sum, s) => sum + (s.pagesRead ?? 0), 0);
    const totalReadingMinutes = Math.floor(
      sessions.reduce((sum, s) => sum + (s.durationSeconds ?? 0), 0) / 60
    );

    const wpmValues = sessions
      .map((s) => s.readingSpeedWpm as number)
      .filter((w) => w > 0);
    const averageWpm =
      wpmValues.length > 0
        ? Math.round(wpmValues.reduce((a, b) => a + b, 0) / wpmValues.length)
        : 0;

    // Weekly WPM history (last 7 days, one average per day)
    const now = new Date();
    const weeklyWpmHistory: number[] = [];
    for (let daysAgo = 6; daysAgo >= 0; daysAgo--) {
      const dayStart = new Date(now);
      dayStart.setDate(now.getDate() - daysAgo);
      dayStart.setHours(0, 0, 0, 0);
      const dayEnd = new Date(dayStart);
      dayEnd.setHours(23, 59, 59, 999);

      const daySessions = sessions.filter((s) => {
        const ts = (s.timestamp as admin.firestore.Timestamp)?.toDate?.();
        return ts && ts >= dayStart && ts <= dayEnd;
      });

      const dayWpm =
        daySessions.length > 0
          ? Math.round(
              daySessions.reduce((sum, s) => sum + (s.readingSpeedWpm ?? 0), 0) /
                daySessions.length
            )
          : 0;
      weeklyWpmHistory.push(dayWpm);
    }

    // Streak: consecutive days with at least one session
    let streakDays = 0;
    const checkDate = new Date(now);
    checkDate.setHours(0, 0, 0, 0);
    while (true) {
      const dayEnd = new Date(checkDate);
      dayEnd.setHours(23, 59, 59, 999);
      const hasSessions = sessions.some((s) => {
        const ts = (s.timestamp as admin.firestore.Timestamp)?.toDate?.();
        return ts && ts >= checkDate && ts <= dayEnd;
      });
      if (!hasSessions) break;
      streakDays++;
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // Books completed: count unique books with 100% progress
    const progressSnap = await db.collection(`users/${userId}/progress`).get();
    const booksCompleted = progressSnap.docs.filter(
      (d) => (d.data().progressPercentage ?? 0) >= 1.0
    ).length;

    // Reading score (0-100)
    const userReadingScore = Math.min(
      100,
      Math.floor(
        streakDays * 5 + Math.min(averageWpm / 4, 25) + booksCompleted * 10
      )
    );

    // ─── Write aggregated stats ─────────────────────────────────────────
    await db.doc(`users/${userId}/stats/main`).set(
      {
        streakDays,
        totalPagesRead,
        totalReadingMinutes,
        booksCompleted,
        averageWpm,
        weeklyWpmHistory,
        userReadingScore,
        lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
);

