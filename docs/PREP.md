# Knob Wars — morning-of checklist (2026-09-17, before 17:00)

Tick in order. ~30 minutes total.

## Tooling
- [ ] `brew install cloudflared` (missing on this Mac as of last night).
- [ ] `cd ~/Documents/projects/knob-wars && npm install` (installs `ws`, `qrcode`, `@anthropic-ai/sdk`).
- [ ] Test the tunnel once: `python3 -m http.server 3000 &` then
      `cloudflared tunnel --url http://localhost:3000` → open the printed `*.trycloudflare.com` URL on the phone over cellular. Note how long allocation took. Kill both.
- [ ] `export ANTHROPIC_API_KEY=...` in `~/.zshenv` **from the console account that holds the event credits** — Claude Code and the game's `/api/hint` route both use it. Never commit it (`.gitignore` covers `.env`).
- [ ] Claude Code desktop app: signed in to that account, this repo opened, permission mode set to auto (no prompts on the clock), effort **high** (not xhigh — speed beats depth for an hour).

## Voice clips (optional, 5 min)
- [ ] `ELEVENLABS_API_KEY=... ./scripts/gen-voice.sh` and play `public/voice/welcome.mp3`.

## Hardware
- [ ] Laptop charged + charger. Phone charged. Video adapter for the projector (USB-C → HDMI).
- [ ] **Speaker.** Ask the organisers if the projector has audio; bring a Bluetooth speaker anyway — a synth demo with no sound is nothing.
- [ ] iPhone hotspot enabled and the laptop joined to it once (so it reconnects instantly). Find the laptop IP on it: `ipconfig getifaddr en0`.

## Rehearsal (10 min)
- [ ] Read `docs/DEMO.md` aloud once with a timer; it must fit in 2:00.
- [ ] Copy the kick-off prompt from `docs/BUILD-PLAN.md` § 2 into a note so it's one paste at 19:00.

## At the venue (18:50)
- [ ] Join the venue Wi-Fi; confirm `claude` responds; confirm `cloudflared` can allocate (else hotspot).
- [ ] Terminal tab 1: ready for `npm start`. Tab 2: ready for `cloudflared tunnel --url http://localhost:3000`.
