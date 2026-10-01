import * as functions from "firebase-functions/v2/auth";
import * as admin from "firebase-admin";

/**
 * Triggered when a new user signs up.
 * Creates their default profile and settings documents in Firestore.
 */
export const onUserCreate = functions.beforeUserCreated(async (event) => {
  const user = event.data;
  if (!user) return;

  const db = admin.firestore();
  const uid = user.uid;
  const displayName = user.displayName ?? "Reader";
  const email = user.email ?? "";

  const batch = db.batch();

  // Create user profile document
  batch.set(db.doc(`users/${uid}/profile/main`), {
    uid,
    displayName,
    email,
    avatarInitial: displayName.substring(0, 1).toUpperCase(),
    joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    readingGoalBooksPerMonth: 2,
    readingGoalPagesPerDay: 30,
  });

  // Create default settings document
  batch.set(db.doc(`users/${uid}/settings/main`), {
    themeMode: "dark",
    readerFontSize: 16.0,
    startInFullScreen: true,
    autoBookmark: true,
    interfaceLanguage: "English",
    primaryDictionaryLanguage: "English",
    secondaryDictionaryLanguage: "Hindi",
    dualLanguageEnabled: true,
  });

  // Create empty stats document
  batch.set(db.doc(`users/${uid}/stats/main`), {
    streakDays: 0,
    totalPagesRead: 0,
    totalReadingMinutes: 0,
    booksCompleted: 0,
    averageWpm: 0,
    weeklyWpmHistory: [0, 0, 0, 0, 0, 0, 0],
    userReadingScore: 0,
    lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();
  functions.logger.info(`Created profile for new user: ${uid} (${email})`);
});

