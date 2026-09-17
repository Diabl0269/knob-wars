# Knob Wars — morning-of checklist (2026-09-17, before 17:00)

Tick in order. ~30 minutes total.

## Tooling
- [x] `brew install cloudflared` — done 2026-09-16 (v2026.9.1).
- [x] `npm install` — done 2026-09-16 (`ws`, `qrcode`, `@anthropic-ai/sdk` 0.126.0 all import).
- [x] Tunnel tested 2026-09-16 from home Wi-Fi: allocated in 7 s, public fetch HTTP 200. Re-test at the venue (18:50) — different network.
- [ ] Put the event console account's key in the repo's **gitignored** `.env` as `ANTHROPIC_API_KEY=...` (the game's `/api/hint` route reads it via `node --env-file=.env`). **Do not export it globally** (`~/.zshenv`/`~/.zshrc`): Claude Code prefers that env var over its logged-in account, so every later session on this Mac would silently bill the console account.
- [ ] Point Claude Code at the credited console account for the hour: switch the account in the desktop app settings (or, for a terminal run, `ANTHROPIC_API_KEY=$(grep ^ANTHROPIC_API_KEY= .env | cut -d= -f2-) claude` on that one launch). Verify with a trivial prompt that usage shows up on console.anthropic.com.
- [ ] Claude Code desktop app: signed in to that account, this repo opened, permission mode set to auto (no prompts on the clock), effort **high** (not xhigh — speed beats depth for an hour).

## Voice clips (optional, 5 min)
- [ ] `ELEVENLABS_API_KEY=... ./scripts/gen-voice.sh` and play `public/voice/welcome.mp3`.

## Hardware
- [ ] Laptop charged + charger. Phone charged. Video adapter for the projector (USB-C → HDMI).
- [ ] **Speaker.** Ask the organisers if the projector has audio; bring a Bluetooth speaker anyway — a synth demo with no sound is nothing.
- [ ] iPhone hotspot enabled and the laptop joined to it once (so it reconnects instantly). Find the laptop IP on it: `ipconfig getifaddr en0`.

## Rehearsal (10 min)
- [ ] Read `docs/DEMO.md` aloud once with a timer; it must fit in 2:00.
- [ ] Copy the kick-off prompt from `docs/BUILD-PLAN.md` § 3 and the bail-out line from § 1 into a note so each is one paste.
- [ ] Read the three demo variants in `docs/DEMO.md`; rehearse variant C with a timer (it must fit 2:00).

## At the venue (18:50)
- [ ] Join the venue Wi-Fi; confirm `claude` responds; confirm `cloudflared` can allocate (else hotspot).
- [ ] Terminal tab 1: ready for `npm start`. Tab 2: ready for `cloudflared tunnel --url http://localhost:3000`.
