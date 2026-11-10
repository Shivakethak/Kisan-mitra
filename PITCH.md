# 🌾 Kisan Mitra: an expert in every farmer's pocket, in their own language

**Challa Shiva Kethak · Amrita Vishwa Vidyapeetham, Bengaluru · Great Indian AI Internship Challenge 2026**

🎬 **[Demo video](https://drive.google.com/file/d/1yQVRL0UiNra8HirQL6m5xq5ucFuNV_Rn/view?usp=sharing)** · 💻 **[Code and setup](README.md)** · 📱 **[Android app](KisanMitra.apk)**

## The problem
India has about **146 million farm holdings**, and agriculture employs about 45% of the workforce. When a crop gets sick, rain is
forecast before spraying, or a farmer needs to know when a scheme payment comes, expert help is far away. Most farmers
**prefer speaking their own language to typing**, many have limited literacy, and existing apps are text-heavy and in English.

## The solution
**Kisan Mitra** is an Android voice assistant. The farmer taps **one big button and talks**, in any of **10 Indian languages
or Hinglish**, and hears a short, practical answer in about **2 seconds**.
- 🗣 **Natural voice conversation:** streaming speech in, streamed speech out, like a phone call.
- 🌦 **Weather-aware advice** from the live forecast at the farmer's GPS location ("rain on Thursday, don't spray yet").
- 📷 **Crop photo diagnosis:** snap a sick leaf and hear the likely problem plus a low-cost remedy.
- 🏛 **Schemes and current facts** (PM-KISAN, PMFBY, KCC, Rythu Bharosa…), with a live-search tool so the answer is given
  *inside the app* instead of sending the farmer elsewhere.
- 👵 **Built for low literacy:** you choose your language by its script and get a spoken confirmation, every label is in your
  language, and buttons are large picture buttons.
- ☎️ **Phone-quality mode (8 kHz)** proves it works on feature-phone and IVR-grade audio.

## How Gnani AI powers it
| Gnani model | Role |
|---|---|
| **Prisma v3.0, streaming STT** (WebSocket, server VAD, `indic-auto`) | Hears the farmer: Indian-language and code-mixed speech, **~105–145 ms** transcription, 16 kHz and 8 kHz |
| **Timbre v2.5, streaming TTS** (WebSocket, per-language voices) | Speaks the answer sentence by sentence, so the first words play before the full answer is written |
| Prisma and Timbre REST | Voice notes and spoken greetings |

Reasoning uses Gemini (raced across a model fallback chain for low latency), because Gnani's Evon v3.3 is not on the API yet.
The LLM layer is pluggable.

## Architecture
Phone mic → 16-bit PCM over WebSocket → FastAPI → **Gnani Prisma stream** → transcript and language → streaming LLM agent
(+ GPS weather, scheme facts, live search) → sentence chunks → **Gnani Timbre stream** → phone speaker.
Barge-in cancels the answer if the farmer speaks. API keys stay on the server; the 56 KB Android app is a secure shell.

## Measured results (real APIs)
Prisma transcription **~105–145 ms** · voice-to-voice **~1.9–2.4 s** · tested in Hindi, Kannada, Telugu and Hinglish at 16 kHz and 8 kHz.

## Impact and next steps
- Scales expert advice to millions of farmers at near-zero marginal cost, and helps KVKs, FPOs and agri helplines handle volume.
- **Next:** a toll-free phone number (Prisma and Timbre support 8 kHz/µ-law natively) so farmers *without smartphones* can call;
  self-hosted **Gnani Evon v3.3** for a fully sovereign Indian stack; grounding in ICAR / state "Package of Practices" crop guides.

**Honest limitations:** general advice, not a replacement for a KVK expert. The government mandi-price API was down during
the build (the bot says so rather than guessing). The app can't see a farmer's personal payment record.
