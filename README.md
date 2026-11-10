<div align="center">

# 🌾 Kisan Mitra
### A voice farm assistant for every Indian farmer

**Tap one button, speak in your own language, and hear expert farm advice in about 2 seconds.**
Built on **Gnani AI Prisma** (speech-to-text) and **Gnani AI Timbre** (text-to-speech).
*Great Indian AI Internship Challenge 2026*

### [🎬 Watch the demo video](https://drive.google.com/file/d/1yQVRL0UiNra8HirQL6m5xq5ucFuNV_Rn/view?usp=sharing) · [📄 One-page pitch](PITCH.md) · [📱 Download the Android app](KisanMitra.apk)

<img src="docs/screenshots/language.png" width="200" alt="Choose your language by its script" />
&nbsp;
<img src="docs/screenshots/home_hi.png" width="200" alt="Hindi home screen" />
&nbsp;
<img src="docs/screenshots/home_kn.png" width="200" alt="Kannada home screen" />
&nbsp;
<img src="docs/screenshots/home_ta.png" width="200" alt="Tamil home screen" />

<sub>Choose your language by its script · one big talk button · every label in the farmer's language</sub>

#### In action: a live Hindi call (Gnani Prisma transcribed in 70 ms)
<img src="docs/screenshots/call_hi.png" width="420" alt="Live voice call in Hindi" />

</div>

---

## The problem
India has about **146 million farm holdings**, and agriculture employs about 45% of the workforce. When a crop gets sick, rain is
forecast before spraying, or a farmer needs to know when a scheme payment arrives, expert help is far away. Most farmers
**prefer speaking their own language to typing**, many have limited literacy, and most agri apps are text-heavy and in English.

## What Kisan Mitra does
| | Feature |
|---|---|
| 🗣 | **Live voice conversation** in **10 Indian languages + Hinglish**. Speak naturally and hear the answer like a phone call. |
| ⚡ | **About 2 s voice-to-voice.** Prisma transcribes in about 120 ms, and Timbre starts speaking while the answer is still being written. |
| 🌦 | **Weather-aware advice** from the live 7-day forecast at the farmer's GPS location ("rain on Saturday, so spray today"). |
| 📷 | **Crop photo diagnosis:** snap a sick leaf and hear the likely problem plus a low-cost remedy. |
| 🏛 | **Government schemes** (PM-KISAN, PMFBY, KCC, Soil Health Card, PM-KUSUM, Rythu Bharosa…), with a live-search tool for current dates and amounts. The answer is given inside the app, not "go check the news". |
| 👵 | **Built for low literacy:** you choose your language by its script and hear a spoken confirmation, every label is in your language, and there is one giant talk button. |
| ☎️ | **Phone-quality mode (8 kHz)** proves it works on feature-phone and IVR-grade audio. |
| ✋ | **Barge-in:** speak over the assistant and it stops and listens (best with headphones). |
| 🩺 | **Built-in System check** that tests every service live from the app. |

## How Gnani AI powers it
| Gnani model | API | Role in Kisan Mitra |
|---|---|---|
| **Prisma v3.0**, speech-to-text | Realtime WebSocket (`/stt/v3/stream`) with server VAD and `indic-auto` language detection | Hears the farmer: regional and code-mixed speech at 16 kHz and 8 kHz, end-of-turn detection, detected language |
| **Prisma**, speech-to-text | REST (`/stt/v3`) | Voice notes in chat mode |
| **Timbre v2.5**, text-to-speech | Realtime WebSocket (`/api/v1/tts`), raw PCM | Speaks each sentence as soon as it's ready, in a native voice per language |
| **Timbre v2.5**, text-to-speech | REST (`/api/v1/tts/inference`) | Spoken greetings and chat answers |

**Reasoning** uses Google Gemini, because Gnani's **Evon v3.3** is not on the Gnani API yet. The LLM layer is pluggable
(Gemini or Claude), and moving to self-hosted Evon v3.3 for a fully sovereign stack is the next step.

## Architecture
```
 Android app / browser
   mic ─► AudioWorklet ─► 16-bit PCM, 1024-byte frames ─► WebSocket /ws/call ─► FastAPI server
                                                                 │
                           ┌─────────────────────────────────────┘
                           ▼
            Gnani Prisma v3.0 streaming STT  (server VAD, indic-auto)
                           │  final transcript + detected language (~120 ms)
                           ▼
            Streaming LLM agent (Gemini, 2 models raced, fallback chain)
              context: GPS weather · location · scheme facts
              tools:   search_latest_info · get_mandi_prices · get_weather_for_place
                           │  text deltas ─► sentence chunker
                           ▼
            Gnani Timbre streaming TTS  (one socket per sentence, next one pre-opened)
                           │  raw PCM
                           ▼
   speaker ◄── jitter-buffered playback ◄── WebSocket
   barge-in: a new utterance cancels the in-flight LLM + TTS and clears the player
```

## Measured performance (real APIs)
| Metric | Result |
|---|---|
| Prisma streaming transcription latency | **~105–145 ms** (16 kHz and 8 kHz) |
| Voice-to-voice (end of speech → first spoken word) | **~1.9–2.4 s** |
| Timbre first audio after a sentence is ready | ~0.2–0.4 s |
| Languages tested end to end | Hindi, Kannada, Telugu, Hinglish |

## Tech stack
**Backend:** Python 3.12, FastAPI, Uvicorn, httpx, websockets
**Frontend:** vanilla HTML/CSS/JS, Web Audio API + AudioWorklet, PWA (manifest + service worker)
**Android:** native Java WebView shell (no third-party libraries, 56 KB) with mic, GPS and camera permissions
**Data:** Open-Meteo (weather), BigDataCloud (reverse geocoding), data.gov.in Agmarknet (mandi prices), web search

## Project structure
```
app/
  main.py        FastAPI: /ws/call (live call), /api/ask (chat + photo), /api/speak, /api/selftest
  call.py        realtime pipeline: STT stream → agent → sentence chunking → TTS stream, barge-in
  gnani.py       Gnani Prisma + Timbre clients (REST + WebSocket)
  llm.py         streaming agent with tool calling; hedged Gemini requests, Claude optional
  tools.py       live search, mandi prices, weather-for-place tools
  weather.py     forecast + geocoding
  knowledge.py   vetted government-scheme facts
static/          farmer-first web app (index.html, app.js, call.js, i18n.js, style.css, sw.js)
android/         Android app source (MainActivity.java, manifest, icons)
docs/screenshots app screenshots
KisanMitra.apk   built Android app
PITCH.md         one-page solution pitch
run.bat / run.sh one-command start (venv, install, key setup, server)
render.yaml      one-click cloud deploy
```

## ▶️ Run it (2 minutes)
**You need:** Python 3.10+, a **Gnani API key** ([app.gnani.ai](https://app.gnani.ai/voice)) and a free **Gemini API key** ([aistudio.google.com/apikey](https://aistudio.google.com/apikey)).
Keys are never stored in this repo. The first run asks for them and saves them only in your local `.env`.

**Windows:** download or clone the repo, then **double-click `run.bat`**.
**macOS / Linux:**
```bash
git clone https://github.com/Shivakethak/Kisan-mitra.git && cd Kisan-mitra
bash run.sh
```
The script creates a virtual environment, installs the dependencies, asks for your two keys (first run only), starts the
server and opens **http://localhost:8000**. Pick a language, tap the green button and talk (allow the microphone).
Then use ⚙️ → **Run system check**: every Gnani service is tested live.

<details>
<summary>Manual setup (any OS)</summary>

```bash
python -m venv .venv
.venv/bin/pip install -r requirements.txt          # Windows: .venv\Scripts\pip ...
cp .env.example .env                                # then fill GNANI_API_KEY and GEMINI_API_KEY
.venv/bin/python -m uvicorn app.main:app --port 8000
```
</details>

**Deploy to the cloud (HTTPS link, needed for phones):** [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shivakethak/Kisan-mitra)
Render reads `render.yaml` and asks for the two keys. The `Dockerfile` also works on any container host.

> ✅ Tested from a clean copy of this repo: `run.bat` installs and starts in under 2 minutes, and the in-app system check passes for Gnani STT (REST + streaming), Gnani TTS (REST + streaming), the LLM and weather.

### Configuration (`.env`)
| Variable | Purpose |
|---|---|
| `GNANI_API_KEY` | Gnani API key (from app.gnani.ai) |
| `STT_MODEL` / `TTS_MODEL` | `prisma-v3.0` / `timbre-v2.5` |
| `LLM_PROVIDER` | `gemini` (default) or `anthropic` |
| `GEMINI_API_KEY`, `GEMINI_MODEL` | Gemini key and a comma-separated fallback chain of models |
| `DATA_GOV_API_KEY` | optional personal data.gov.in key for mandi prices |

## Android app
1. Get an HTTPS link for the server: the **Deploy to Render** button above, or `cloudflared tunnel --url http://localhost:8000` for a quick test.
2. Install `KisanMitra.apk` on the phone (allow "Install unknown apps").
3. Open the app, enter the server link once, and allow the mic and location.

**API keys stay on the server and are never inside the APK.** To rebuild: `cd android && gradle assembleDebug` (JDK 17, Android SDK 34).

## Honest limitations
- Reasoning is a hosted LLM (Gemini), not a Gnani model, because Evon v3.3 isn't on the Gnani API yet.
- This is general advice, not a replacement for a KVK expert; it says so for serious cases.
- The government Agmarknet mandi-price API was down during the build. The bot then says so instead of guessing.
- Live search quality depends on the Gemini plan (Google Search grounding needs the paid tier; the free fallback is best-effort).
- The app can't see a farmer's personal payment record. It explains likely reasons and fix steps instead.
- Barge-in works best with headphones, because browser echo cancellation is imperfect.

## Roadmap
- **Toll-free phone number** (telephony media streams → the same pipeline; Prisma and Timbre support 8 kHz/µ-law natively) for farmers without smartphones
- **Self-hosted Gnani Evon v3.3** for a fully sovereign Indian AI stack
- Grounding in ICAR / state agricultural university "Package of Practices" crop guides and IMD agromet advisories
- Proactive alerts: rain-before-spraying, pest outbreaks, scheme instalment releases

---
**Author:** Challa Shiva Kethak · Amrita Vishwa Vidyapeetham, Bengaluru
