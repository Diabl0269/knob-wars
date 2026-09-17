# Knob Wars — Build plan (60 minutes, 19:00–20:00)

Built by **checkpoints**, not phases: each checkpoint is a demoable game on its own, has a hard
deadline, and has its own 2-minute demo variant in `docs/DEMO.md`. If a checkpoint is not verified
by its deadline, **stop building that checkpoint, revert to the last commit, and go to demo prep.**
Claude's active build time is ~35 minutes; the rest is your phone test, rehearsal, and slack.

## 0. Cut list (read first)

Cut from the top when behind. Never cut below the line.

1. Rotary knobs (sliders stay)
2. Claude Sensei hint (rule-based hint stays)
3. Global all-time leaderboard file
4. Visual extras in VISUAL.md §4 order: living background → streaks → shake → FLIP → level-up slide → confetti
5. Levels 9–10 (reverb, detune)
6. Hand-authored named targets (random targets stay)
7. Arena: multiple rounds (one round + results is enough for the demo)
8. Arena entirely — the demo variant B still works (solo + phone)
---------------------------------------------------------------- never cut below this line
- Solo: levels 1–4, lesson card, scoring, results bars, level-up
- Theme + wave icons, timer ring, score count-up, accuracy bars, oscilloscope (VISUAL.md)
- iOS audio unlock, phone layout
- Each device plays its own audio ("Hear target" / "Hear mine")

## 1. Checkpoints

| Checkpoint | Deadline | Contents | Demoable as |
|---|---|---|---|
| **A — Solo core** | **19:18** | `shared/patch.js` (schema, LEVELS, LESSONS, randomTarget), `shared/scoring.js`, `engine.js` (unlock tap, phrase, voice graph), `controls.js`, `play.html`/`play.js` solo campaign, `app.css` with VISUAL.md theme (tokens, wave icons, chunky buttons, slider pill, phone layout), static `server/index.js`. Levels 1–10 in data, 1–4 verified. | "Solo synth trainer": hear, match, score, level up. |
| **B — Spectacle** | **19:32** | `fx.js`: oscilloscope, score count-up + speed label, bars sweep, level-up/lesson card reveal, timer ring (solo shows the 120 s bonus window), confetti on ★★★; announcer clips + speech fallback; finish screen with AgentSynth link; rule-based hint. | Polished solo game on the projector — the full demo works with this alone. |
| **C — Arena** | **19:45** | ws rooms in `server/index.js`, `net.js`, `host.html`/`host.js` (QR, lobby, timer ring, join pops, submitted ticks, results podium, leaderboard with FLIP or instant re-sort), arena mode in `play.js`, "Quick game" preset (3 × 60 s). | + "beat the room": laptop host, phone player, live leaderboard. |
| **D — Stretch** | only if C verified by 19:42; hard stop **19:48** | Cut-list items bottom-up: named targets, global leaderboard, Sensei hint, knobs. | — |
| **Freeze** | **19:48** | `git commit`. No more code. Demo prep per `docs/DEMO.md` for the variant you reached. | |

Bail-out rule, literally: at 19:18 / 19:32 / 19:45, if Claude hasn't printed "Checkpoint X verified",
paste: `Stop. git checkout the last commit. Tell me what works right now.` and start demo prep.

## 2. Timeline

| Clock | Claude | You |
|---|---|---|
| 19:00 | Kick-off prompt (below). Builds A. | Start `cloudflared` in a terminal tab. Open the phone on the tunnel URL. |
| 19:18 | "Checkpoint A verified". Builds B. | Phone-test A: unlock tap, hear target/mine, slider feel, submit, results. Collect issues; don't interrupt. |
| 19:32 | "Checkpoint B verified". Builds C. | Phone-test B on the phone and on the laptop tab (that's the projector). **Check console usage**; if > $60, paste "skip D". |
| 19:45 | "Checkpoint C verified" or bail-out. D only if early. | Paste your issue list as the fix prompt (below); it runs during D's window. |
| 19:48 | Freeze. | Rehearse the demo variant once with the timer. Restart server, confirm tunnel URL. |
| 19:55 | — | Host/solo page fullscreen, volume up, phone joined. |

## 3. Kick-off prompt (paste verbatim at 19:00)

```
Read CLAUDE.md, docs/DESIGN.md, docs/VISUAL.md and docs/BUILD-PLAN.md once. Build checkpoints
A, B, C in that order without stopping between them. Every decision is already made in the docs;
don't ask me anything. Work inline in this session, no Fable subagents. After each checkpoint:
verify it yourself in the browser (open the pages, check the console, click through a full
level/round), commit, and print exactly "Checkpoint X verified" plus one line of what to test on
my phone. Deadlines: A by 19:18, B by 19:32, C by 19:45 — if you're going to miss one, ship the
smallest version that is demoable and say so rather than pushing past it. No frameworks, no CDNs.
```

## 4. Fix prompt (paste at ~19:45 with your notes)

```
Fix these from my phone/laptop test, in this order, verifying each in the browser: <list>.
Commit after each. Hard stop at 19:48; then tell me exactly what works and what doesn't.
```

## 5. Spend (Fable 5.1: $10/M in, $50/M out, $0.25/M cache read)

Expected $25–45 for ~35 minutes of one session with small files; ceiling $70. Guardrails: one
session, no re-reading docs, subagents on Sonnet only, usage check at 19:32. If a bug loops for
> 4 minutes, revert and re-scope.

## 6. If things go wrong

| Problem | Do |
|---|---|
| A slips past 19:18 | Ship solo with levels 1–2 only; B still runs on top of it. |
| B slips | Demo variant A (the game is still playable; say the visuals are next). |
| C slips or Wi-Fi/tunnel is dead | Demo variant B; arena is "next up". Show the host page if it renders. |
| Phone has no sound | Silent switch; show the laptop tab instead, mention it plays on every device. |
| Claude stuck | `Stop. Revert to last commit. Implement the minimum for checkpoint X per DESIGN.md.` |
