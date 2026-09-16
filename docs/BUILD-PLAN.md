# Knob Wars — Build plan (60 minutes, 19:00–20:00)

The clock starts at 19:00. Claude works ~40 minutes; the human tests on a phone and rehearses in
the rest. Phases are ordered so that **at any minute, what exists is demoable**.

## 0. Cut list (read this first — it decides what survives)

If behind schedule, cut from the top. Never cut anything below the line.

1. Rotary knobs (sliders stay)
2. Claude Sensei hint (rule-based hint stays)
3. Global all-time leaderboard file (per-game leaderboard stays)
4. Levels 9–10 (reverb, detune) — levels 1–8 stay
5. Hand-authored named targets (random targets stay)
6. "Play winner's patch" on the host page
7. Animated leaderboard re-sort
8. Reconnect handling (a refresh = rejoin with the same name is fine)
---------------------------------------------------------------- never cut below this line
- Solo mode, levels 1–4, scoring, results bars
- Arena: host QR, join, 1 round, results, leaderboard
- Demo preset (3 rounds × 30 s)
- iOS audio unlock, phone layout

## 1. Timeline

| Clock | Min | Who | What |
|---|---|---|---|
| 19:00 | 0 | Human | Open `claude` in this repo, paste the **kick-off prompt** below. Start `cloudflared` in a terminal tab now (allocation can take a minute). |
| 19:00 | 0–13 | Claude | **Phase 1 — Solo core**: `shared/patch.js`, `shared/scoring.js`, `engine.js`, `controls.js`, `play.html`+`play.js` solo campaign (levels 1–10 in data, verified on 1–4), `app.css`, `server/index.js` static only, `npm start`. Verify in browser: tap-to-start, target plays, sliders, submit, results, next level. Commit. Say **"Phase 1 ready for phone test"**. |
| 19:13 | 13–27 | Claude | **Phase 2 — Arena**: ws rooms, `host.html`+`host.js` (QR via `/qr`, lobby, countdown, submitted list, podium, leaderboard), `net.js`, arena mode in `play.js`, demo preset, auto-submit at timeout. Verify two tabs end-to-end. Commit. Say **"Phase 2 ready for phone test"**. |
| 19:13 | 13–27 | Human | Phone test Phase 1 over the tunnel: audio unlock, slider feel, layout, results. Note issues; **don't interrupt Claude** — collect them for Phase 4. |
| 19:27 | 27–37 | Claude | **Phase 3 — Delight**: announcer (`public/voice` + speech fallback), level names + unlock reveal animation, `shared/targets.js` named targets, results bars with real units, agentsynth.app link on the finish screen, rule-based hint. Commit. |
| 19:27 | 27–37 | Human | Phone test Phase 2 (join from phone, host on laptop). **Minute 30: check console usage** — if > $60, tell Claude "skip stretch". |
| 19:37 | 37–45 | Claude | **Phase 4 — Fixes + stretch** (hard stop 19:45): the human's issue list first (paste it), then stretch in cut-list order bottom-up: Claude Sensei hint, global leaderboard, knobs. Commit. |
| 19:45 | 45–55 | Human | Full rehearsal of `docs/DEMO.md` with the phone + laptop speakers. Restart server; confirm the tunnel URL still resolves. |
| 19:55 | 55–60 | Both | **Freeze.** No more code. `git commit`. Open `/host`, fullscreen, room created, QR on screen, volume up. |

## 2. Kick-off prompt (paste verbatim at 19:00)

```
Read CLAUDE.md, docs/DESIGN.md and docs/BUILD-PLAN.md once. Then build Phases 1, 2 and 3 in
order without stopping between them. Every decision is already in DESIGN.md — don't ask me
anything, decide and move on. After each phase: verify it yourself in the browser (open the
pages, check the console, click through a full round), commit, and print one line
"Phase N ready for phone test" so I can test on my iPhone while you continue. Keep files small,
no frameworks, no CDNs. Don't spawn Fable subagents; if you parallelize, use Sonnet. Go.
```

## 3. Phase 4 prompt (paste at ~19:37, with your notes)

```
Phase 4. First fix these from my phone test, in this order: <paste list>. Verify each in the
browser. Then, only if it's before 19:45, add stretch items in this order: Claude Sensei hint
(DESIGN.md §10, ANTHROPIC_API_KEY is in .env, loaded by npm start), global top-20 leaderboard file, rotary knobs.
Commit after each. Stop at 19:45 regardless and tell me exactly what's in and what's out.
```

## 4. Phase details (what "done" means)

**Phase 1 done** = on `localhost:3000/play`: tap to start → level 1 target plays a riff → 4 wave
buttons → Hear target / Hear mine → Submit → results show accuracy + target vs mine → Next →
level 2 shows a cutoff slider. Levels 1–10 exist in data; 1–4 clicked through. Console clean.

**Phase 2 done** = `/host` shows a QR + room code; `/play?room=CODE` in a second tab joins and
appears on the host; "Demo" starts round 1 with a 30 s countdown on both; submitting on the phone
tab shows a tick on host; at 0 s both show results and the leaderboard updates; 3 rounds → finished.

**Phase 3 done** = host speaks "Welcome to Knob Wars" on room creation and "Time's up" at 0 s
(mp3 or speech fallback); results show real units; finish screen has the AgentSynth link.

**Phase 4 done** = human's list fixed; whatever stretch landed is committed and listed.

## 5. Spend budget (Fable 5.1: $10/M in, $50/M out, $0.25/M cache read)

| Item | Estimate |
|---|---|
| ~35 turns, ~50k context each, mostly cached | ~$8–15 |
| Cache writes / fresh reads of docs + code | ~$10–15 |
| ~120k output tokens (code + thinking) | ~$6–10 |
| Two Sonnet subagents (optional) | ~$3 |
| **Expected total** | **$25–45**, ceiling $70 |

Guardrails: one main session, small files, no re-reading docs, subagents on Sonnet only,
usage check at minute 30. If a phase is looping on a bug for > 4 minutes, `git checkout` the
last commit and re-scope instead of pushing on.

## 6. If things go wrong

| Problem | Do |
|---|---|
| Tunnel never allocates | Laptop + phone on the iPhone hotspot; use `http://<laptop-LAN-IP>:3000` (see PREP.md). |
| No network at all | Demo Arena with two browser windows on the laptop + Solo on the phone (offline works). |
| Phone has no sound | Expected on silent switch; the host laptop is the audio source anyway. Say so. |
| ws rooms buggy at 19:40 | Cut arena to a single round; the demo preset only needs rounds to *display*. |
| Claude stuck | Paste: "Stop. Revert to last commit. Implement the minimum for <phase> per DESIGN.md §N only." |
