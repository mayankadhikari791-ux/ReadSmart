import { onCall, HttpsError } from "firebase-functions/v2/https";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { defineSecret } from "firebase-functions/params";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

interface ReadingStats {
  averageWpm: number;
  streakDays: number;
  totalPagesRead: number;
  booksCompleted: number;
  vocabularyCount: number;
}

interface ReadingTip {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  badgeText: string;
  actionText?: string;
  category: "speed" | "comprehension" | "vocabulary" | "focus" | "habit";
}

/**
 * Callable: Generate personalized AI reading tips using Gemini.
 * Accepts the user's reading stats and returns 3-4 personalized tips.
 */
export const getReadingTips = onCall<ReadingStats>(
  {
    region: "asia-south1",
    secrets: [geminiApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be signed in.");
    }

    const { averageWpm, streakDays, totalPagesRead, booksCompleted, vocabularyCount } =
      request.data;

    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 1024,
        responseMimeType: "application/json",
      },
    });

    const prompt = `You are a personalized reading coach AI for the ReadSmart app. 
Generate 4 concise, actionable reading improvement tips based on this reader's stats:

- Average reading speed: ${averageWpm} WPM
- Current streak: ${streakDays} days
- Total pages read: ${totalPagesRead}
- Books completed: ${booksCompleted}
- Vocabulary words saved: ${vocabularyCount}

Return a JSON array of exactly 4 tip objects. Each object must have these exact fields:
{
  "id": "tip_ai_<number>",
  "title": "<2-4 word title>",
  "subtitle": "<short context, e.g. stat or method name>",
  "description": "<1-2 sentence actionable tip, max 120 chars>",
  "badgeText": "<short badge label>",
  "actionText": "<optional: short CTA button text, omit if not applicable>",
  "category": "<one of: speed | comprehension | vocabulary | focus | habit>"
}

Be specific to their actual numbers. Don't give generic advice — reference their stats directly.`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    let tips: ReadingTip[];
    try {
      tips = JSON.parse(text);
    } catch {
      // Fallback if JSON parse fails
      tips = [
        {
          id: "tip_ai_1",
          title: "Keep Going!",
          subtitle: `${averageWpm} WPM average`,
          description: `You're reading at ${averageWpm} WPM. Focus on comprehension first — speed will follow naturally.`,
          badgeText: "Speed Tip",
          category: "speed",
        },
      ];
    }

    return { tips };
  }
);

