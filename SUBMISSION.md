# Submission kit

## Project title
Kisan Mitra: a real-time voice farm assistant in 10 Indian languages

## Problem solved (form field)
India has about 146M farm holdings, and most farmers prefer speaking their language to typing. Timely expert advice on pests,
weather-safe spraying, mandi prices and government schemes is hard to reach. Kisan Mitra is an Android app where a farmer
taps one big button and just talks. It listens with Gnani Prisma, reasons with live local weather, live web search for the
latest scheme dates and amounts, vetted scheme facts and crop-photo diagnosis, and replies by voice with Gnani Timbre in
about 2 seconds, in their own language. It is built for low literacy: you pick your language by its script, get a spoken
confirmation, and every label is in your language.

## Target users
Small and marginal farmers across India, including low-literacy users and phone-quality (8 kHz) audio. Also useful for
KVKs, FPOs and agri helplines that need to scale expert advice.

## Gnani models/APIs used
- Prisma v3.0, realtime streaming STT (WebSocket, server VAD, indic-auto detection, 16 kHz and 8 kHz telephony)
- Prisma REST STT (chat mode)
- Timbre v2.5, realtime WebSocket TTS (streamed raw PCM, per-language voices) and REST TTS

## Written explanation
Kisan Mitra is a full-duplex voice agent. The browser streams 16-bit PCM in 1024-byte frames over a WebSocket to a
FastAPI server, which relays it to Prisma's streaming endpoint. Prisma's VAD detects the end of the turn and returns
the transcript with the detected language in about 110–145 ms. A streaming LLM agent (Gemini, hedged across a model fallback chain; Claude optional) answers in that same
language, grounded in the farmer's GPS weather forecast, a curated scheme knowledge base, and tool calls to the
Government's Agmarknet mandi-price API. Its output is cut into sentences on the fly, and each sentence is synthesised
by Timbre's WebSocket TTS (with the next socket pre-opened), so the farmer hears the first words before the full answer is
written. If the farmer speaks over the bot, the in-flight answer is cancelled (barge-in). A phone-quality mode runs the
whole loop at 8 kHz to mimic feature-phone and IVR calls. For time-sensitive questions (scheme instalment dates, MSP,
deadlines) the agent calls a live web-search tool, so the answer is given inside the app instead of sending the
farmer elsewhere. It ships as a 56 KB native Android app (a WebView shell with mic, GPS and camera permissions; API keys
stay on the server) and also installs as a PWA. A built-in "System check" tests every service live.
Limitations: Gnani Prisma and Timbre power all of the voice, but the reasoning uses Gemini because Evon v3.3 is not on
the Gnani API yet (moving to self-hosted Evon is the next step); barge-in needs headphones; the government Agmarknet
mandi API was down during the build, in which case the bot says so instead of guessing; the app cannot see a farmer's
personal payment record.

## Team contribution
(fill in: who did what)

---

## LinkedIn / X post (edit the [brackets])
🌾 What if every farmer in India could just *call* an expert, in their own language, and get an answer in about two seconds?

For the #GreatIndianAIInternshipChallenge I built **Kisan Mitra**, a real-time voice assistant for farmers, built on @Gnani AI's voice models:

🎙 Gnani Prisma streaming speech-to-text in 10 Indian languages + Hinglish, with auto language detection
🔊 Gnani Timbre streaming text-to-speech that replies in a native voice
⚡ About 2 s voice-to-voice (Prisma transcribes in about 120 ms), and you can interrupt it like a real person
☎️ Works on 8 kHz phone-quality audio
🌦 Weather-aware advice ("rain on Thursday, don't spray yet")
📷 Snap a sick leaf and hear the diagnosis
🏛 Live search for scheme dates and amounts (PM-KISAN, Rythu Bharosa…), answered inside the app
📱 Android app built for low-literacy users: one big button, every label in your language

Demo 👇 [video]
Code: [GitHub link]

India has about 146M farm holdings. Most farmers would rather talk than type. Voice AI built for India can reach them.

@Gnani AI #GnaniAI #GreatIndianAIInternshipChallenge #VoiceAI #AgriTech #BuildForBharat

(X version, under 280 characters):
🌾 Kisan Mitra: farmers just *call* and get expert advice in their own language in about 2s. Built on @gnani_ai Prisma STT + Timbre TTS: 10 Indian languages, interruptible, live mandi prices and weather. Demo 👇 #GreatIndianAIInternshipChallenge #GnaniAI

---

## 60-second demo script (targets the Demo Day Drop award)
| Time | Shot |
|---|---|
| 0–5 s | Hook text on screen: "146 million farmers. One button." Show the language picker, tap हिन्दी, and the spoken greeting plays. |
| 5–20 s | Tap the big green button. **Hindi:** "मेरे टमाटर के पत्ते पीले होकर मुड़ रहे हैं, क्या करूँ?" Show the live captions and the "⚡ voice-to-voice" line. |
| 20–30 s | Same call: "क्या इस हफ्ते बारिश होगी? दवा कब छिड़कूँ?" It answers with the real forecast. |
| 30–42 s | End the call, switch the language to **Kannada** (or Telugu), tap Talk, and ask a paddy fertiliser question. It replies in a Kannada voice. |
| 42–55 s | Tap 📷 **Crop photo**, snap a real leaf, and the diagnosis is shown and spoken. |
| 55–60 s | End card: "Kisan Mitra · Built on Gnani Prisma + Timbre · #GreatIndianAIInternshipChallenge" |

Skip mandi prices in the demo: the government API was down. Do one practice run first; your free Gemini quota is limited.

Tips: wear headphones (for barge-in), record the screen plus mic (Windows: Win+Alt+R with Xbox Game Bar, or OBS), use
captions, and put the latency line on screen. Gnani cares about latency.
