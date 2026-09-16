# CLAUDE.md — Knob Wars (Claude Code Fable 5.1 Build Day, Tel Aviv, 2026-09-17)

**Knob Wars** is a multiplayer ear-training synth game: hear a sound, rebuild it on your
own synth, beat the room. Levels unlock more synth controls as you progress (Syntorial-style),
solo or against others, on laptop / iPad / phone. Built live in the event's one-hour build slot.

This file is the brief for the build session. Read it, then `docs/BUILD-PLAN.md`, then go.
`docs/DESIGN.md` has every decision already made (schema, scoring, levels, protocol,
file layout) — **do not redesign, do not ask; build**. `docs/VISUAL.md` is the look and game-feel
spec: **this is a game and it must look spectacular on the projector** — neon arcade theme, live
oscilloscope, timer ring, count-ups, confetti, animated leaderboard — all CSS transforms/opacity
and two small canvases, no libraries. Build the visuals in the phase they're assigned to; don't
leave them for "later".

## Hard constraints

- **60 minutes total, target 40 minutes of Claude work.** The human needs ~15 min to test on a
  phone and rehearse the demo. Phase order and cut list in `docs/BUILD-PLAN.md` are binding.
- **$100 API credits for the whole hour.** Fable 5.1 is $10/M in, $50/M out, $0.25/M cache reads.
  Spend rules below.
- **Demo is 2 minutes, in front of a room, audience joins from their phones via QR.** The host
  laptop is the *only* audio source that matters; phones are controllers (with optional local sound).
- **Responsive, touch-first.** Phone portrait is the primary layout for players; the host page is
  a landscape "big screen" for the projector.

## Stack (fixed — zero build step, zero framework)

- Node 24, `"type": "module"`. `server/index.js` = `node:http` static server + `ws` WebSocket +
  two tiny routes (`/qr`, `/api/hint`). Deps already installed: `ws`, `qrcode`, `@anthropic-ai/sdk`.
- Frontend: plain HTML + ES modules + CSS. Web Audio API directly (no Tone.js, no CDN — venue
  Wi-Fi may be bad). `shared/*.js` is dependency-free ESM imported by both server and browser.
- Run: `npm start` → http://localhost:3000. Public URL: `cloudflared tunnel --url http://localhost:3000`.
- Solo mode must work with **no server round-trip** (client-only), so it works even if networking fails.

## Non-negotiables (each has bitten someone before)

1. **iOS audio unlock**: create/resume the `AudioContext` inside a user tap handler ("Tap to start").
   Nothing plays on iPhone otherwise. Do this first in `engine.js`.
2. **Scoring is server-authoritative in multiplayer** and uses the *same* `shared/scoring.js` the
   client uses for solo. One function, one truth.
3. **All patch params are normalized 0..1** in the patch object; the engine maps to Hz/seconds.
   Waveform is the only categorical param. See `docs/DESIGN.md` § Patch schema.
4. **Locked controls are pinned to defaults** in both target and player patch, so a level only
   scores the controls it has unlocked.
5. **Commit at the end of every phase** (`git commit -am "phase N"`), so a broken phase can be reverted
   instead of debugged on the clock.
6. **Verify in the browser yourself** (preview tools: open the page, read console, click, screenshot)
   before reporting a phase done. Never ask the human to check something you can check.
7. Keep every file under ~300 lines. Small files = fewer tokens re-read = cheaper and faster.

## Work inline (overrides the global "delegate to subagents" preference for this hour)

The global `~/.claude/CLAUDE.md` says to orchestrate and delegate legwork to subagents. **Not here.**
A 40-minute solo build has no room for handoffs: write the code yourself, in this session,
sequentially. Subagents only for the narrow case in the spend rules below.

## Spend rules (the $100)

- One Fable 5.1 session (this one). Subagents, if any, run on **Sonnet 5** (`model: sonnet`), max two
  at once, only for independent leaf work (e.g. CSS polish while the server is being written).
- Don't `cat` whole files you just wrote; don't re-read `docs/` after the first read.
- At **minute 30** the human checks console usage. If spend > $60, skip all stretch items.
- In-game Claude calls (`/api/hint`) are ~500 tokens each; irrelevant to the budget.

## Verification recipe

- Laptop: `npm start`, open `/host` and `/play?room=XXXX` in two tabs, play a round end-to-end.
- Phone: the human opens the tunnel URL from the QR on `/host`. Announce **"Phase N ready for phone
  test"** the moment a phase is verified on laptop, then continue with the next phase without waiting.
- Console must be clean (no uncaught errors) on both pages.

## What was prepared before the event vs built live (say this to judges)

Prepared: this brief, the design docs, `package.json` with deps installed, `cloudflared`, and the
announcer voice clips in `public/voice/`. **Built live: all code** (`server/`, `shared/`, `public/`
except the voice clips). The event page sets no rule on prep; this is the honest line either way.
