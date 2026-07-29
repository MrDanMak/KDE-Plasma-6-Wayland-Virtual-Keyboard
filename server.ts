import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let aiClient: GoogleGenAI | null = null;
let geminiCooldownUntil = 0;

function getGenAI(): GoogleGenAI | null {
  if (Date.now() < geminiCooldownUntil) {
    return null; // In cooldown period due to 429 quota limit
  }
  if (!aiClient && process.env.GEMINI_API_KEY) {
    aiClient = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
      httpOptions: {
        headers: {
          "User-Agent": "aistudio-build",
        },
      },
    });
  }
  return aiClient;
}

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // API Route: Health check
  app.get("/api/health", (_req, res) => {
    res.json({ status: "ok", mode: "KDE Plasma 6 Virtual Keyboard Backend" });
  });

  // API Route: Word completion and smart suggestion
  app.post("/api/suggest", async (req, res) => {
    try {
      const { text, promptType } = req.body;
      const ai = getGenAI();

      if (ai) {
        let systemPrompt = "You are an on-screen keyboard auto-completion engine for KDE Plasma 6 Wayland. Provide 3 likely next word or completion candidates based on context. Return strictly a JSON array of 3 strings.";
        if (promptType === "fix") {
          systemPrompt = "Fix spelling/grammar in the input text and return 3 variations/corrections as a JSON array of strings.";
        } else if (promptType === "swype") {
          systemPrompt = "Given a typed sequence or swipe trajectory context, return 3 candidate words as a JSON array of 3 strings.";
        }

        const response = await ai.models.generateContent({
          model: "gemini-3.6-flash",
          contents: `Context text: "${text || ""}"`,
          config: {
            systemInstruction: systemPrompt,
            responseMimeType: "application/json",
          },
        });

        if (response.text) {
          const suggestions = JSON.parse(response.text.trim());
          if (Array.isArray(suggestions)) {
            return res.json({ suggestions: suggestions.slice(0, 4) });
          }
        }
      }

      // Fallback algorithmic suggestions
      return res.json({
        suggestions: fallbackSuggest(text || "", promptType),
      });
    } catch (err: any) {
      const isRateLimit = err?.status === 429 || err?.message?.includes("429") || err?.message?.includes("quota");
      if (isRateLimit) {
        geminiCooldownUntil = Date.now() + 60000; // 1 minute cooldown
        console.warn("[OSK Backend] Gemini API rate limit reached. Using local KDE dictionary fallback for 60s.");
      } else {
        console.warn("[OSK Backend] Suggestion error, using fallback:", err?.message || err);
      }
      return res.json({
        suggestions: fallbackSuggest(req.body?.text || "", req.body?.promptType),
      });
    }
  });

  // Vite middleware setup
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (_req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`KDE Plasma 6 OSK Server listening on http://0.0.0.0:${PORT}`);
  });
}

function fallbackSuggest(text: string, promptType?: string): string[] {
  const words = text.trim().split(/\s+/);
  const lastWord = words[words.length - 1]?.toLowerCase() || "";

  if (promptType === "fix") {
    return [text, text.toLowerCase(), text.toUpperCase()];
  }

  const dictionary = [
    "the", "be", "to", "of", "and", "a", "in", "that", "have", "I", "it", "for", "not", "on", "with", "he",
    "as", "you", "do", "at", "this", "but", "his", "by", "from", "they", "we", "say", "her", "she", "or",
    "an", "will", "my", "one", "all", "would", "there", "their", "what", "so", "up", "out", "if", "about",
    "who", "get", "which", "go", "me", "when", "make", "can", "like", "time", "no", "just", "him", "know",
    "take", "people", "into", "year", "your", "good", "some", "could", "them", "see", "other", "than",
    "then", "now", "look", "only", "come", "its", "over", "think", "also", "back", "after", "use", "two",
    "how", "our", "work", "first", "well", "way", "even", "new", "want", "because", "any", "these", "give",
    "day", "most", "us", "plasma", "wayland", "linux", "kde", "keyboard", "surface", "touch", "swype", "tablet"
  ];

  if (!lastWord) {
    return ["the", "I", "Plasma", "Wayland"];
  }

  const matched = dictionary.filter(w => w.toLowerCase().startsWith(lastWord));
  if (matched.length > 0) {
    return matched.slice(0, 4);
  }

  return [lastWord + "s", lastWord + "ing", lastWord + "ed"];
}

startServer();
