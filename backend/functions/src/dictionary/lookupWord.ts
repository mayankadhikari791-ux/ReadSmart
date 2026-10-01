import { onCall, HttpsError } from "firebase-functions/v2/https";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { defineSecret } from "firebase-functions/params";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

interface LookupWordData {
  word: string;
  sentence?: string;
  bookTitle?: string;
  primaryLanguage: string;
  secondaryLanguage: string;
}

interface WordDefinition {
  word: string;
  pronunciation: string;
  partOfSpeech: string;
  cefrLevel: string;
  englishMeaning: string;
  exampleSentence: string;
  synonyms: string[];
  secondaryWord: string;
  secondaryMeaning: string;
  memoryTip: string;
}

/**
 * Callable: Smart dictionary — look up a word with AI-powered definitions.
 * Returns pronunciation, meaning, CEFR level, synonyms, and bilingual definition.
 */
export const lookupWord = onCall<LookupWordData>(
  {
    region: "asia-south1",
    secrets: [geminiApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be signed in.");
    }

    const { word, sentence, bookTitle, primaryLanguage, secondaryLanguage } = request.data;

    if (!word || word.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Word cannot be empty.");
    }

    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
      generationConfig: {
        temperature: 0.3,
        maxOutputTokens: 512,
        responseMimeType: "application/json",
      },
    });

    const contextHint = sentence
      ? `The word was found in this sentence: "${sentence}"`
      : "";
    const bookHint = bookTitle
      ? `from the book "${bookTitle}"`
      : "";

    const prompt = `You are a smart bilingual dictionary for readers. 
Define the word "${word}" ${bookHint} for a reader.
${contextHint}

Return a single JSON object with exactly these fields:
{
  "word": "${word}",
  "pronunciation": "<IPA pronunciation, e.g. /ˈwɜːrd/>",
  "partOfSpeech": "<noun | verb | adjective | adverb | etc.>",
  "cefrLevel": "<CEFR level: A1 | A2 | B1 | B2 | C1 | C2>",
  "englishMeaning": "<clear ${primaryLanguage} definition, max 80 chars>",
  "exampleSentence": "<short example sentence using the word>",
  "synonyms": ["<synonym1>", "<synonym2>", "<synonym3>"],
  "secondaryWord": "<the ${secondaryLanguage} word for this, e.g. Hindi translation>",
  "secondaryMeaning": "<meaning in ${secondaryLanguage}, max 100 chars>",
  "memoryTip": "<1 short memory trick or etymology tip, max 80 chars>"
}`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    let definition: WordDefinition;
    try {
      definition = JSON.parse(text);
    } catch {
      throw new HttpsError("internal", "Failed to parse AI response.");
    }

    return { definition };
  }
);

