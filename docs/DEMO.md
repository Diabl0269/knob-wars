# Knob Wars — 2-minute demo

The demo is **scripted and self-contained**: it runs on the laptop (projector) with your phone in
hand, and never depends on the audience joining. The QR goes up at the end as the closer;
judges and the room play during judging (20:00–20:30), not during the two minutes.
Pick the variant matching the checkpoint you reached. Say the honesty line if asked.

## Variant C (arena landed) — 2:00

Setup: laptop tab 1 = `/play` solo at level 1, tab 2 = `/host` with a room created; phone joined to
the room as a player (and a friend pre-joined if one is next to you). Laptop audio to the room.

| Time | Say | Do |
|---|---|---|
| 0:00 | "Knob Wars teaches synthesis by ear, as a game. You hear a sound and rebuild it." | Tab 1. Tap Hear target — the oscilloscope moves. |
| 0:15 | "Level one is just the shape." | Tap the saw icon, Hear mine, Submit → score counts up, ★★★, confetti. |
| 0:35 | "Every level unlocks one more control and teaches it in one sentence." | Level-up card: read the lesson aloud. Cutoff slider appears; move it while a note holds. |
| 0:55 | "Ten levels: filter, envelope, LFOs, delay, reverb. Solo, or against the room." | Switch to tab 2 (host). |
| 1:05 | "Same game, multiplayer: everyone gets the same target, closest ear wins the round." | Start Quick game. Target plays on the room speakers. On your phone: tweak, Submit → tick on host. |
| 1:35 | "Leaderboard." | Round ends (or tap End round). Podium, leaderboard re-sort, announcer. |
| 1:45 | "Built in the last hour with Fable 5.1. It's live now — scan and play a round while you judge. It links to AgentSynth, the real synth I'm building." | Show QR fullscreen. Done. |

## Variant B (solo + visuals) — 2:00

Same first 55 s, then: "Multiplayer is the next hour: rooms, live leaderboard." Continue solo:
level 3 (resonance) or 4 (pluck vs pad) on the **phone**, held up, to show it's mobile. Close at
1:45 with the QR to the solo game and the AgentSynth line.

## Variant A (solo core only) — 1:30

Play levels 1 → 2 → 3 on the laptop, narrating the lesson each time; close with the QR.
Shorter is fine — a working game beats a padded demo.

## Audio in the room

Every device plays its own audio (that's how players compare target and their patch). For the
demo the **laptop** is what the room hears, so run the solo part on the laptop tab, not the phone.
Bring a Bluetooth speaker in case the projector has none.

## Announcer lines (ElevenLabs, generated before the event)

| id | line |
|---|---|
| welcome | Welcome to Knob Wars. Listen, match, and level up. |
| round | New round. Listen closely. |
| ten | Ten seconds. |
| timeup | Time's up! Let's see the scores. |
| levelup | Level up! New control unlocked. |
| winner | We have a winner! |
| highscore | New high score! |
| gameover | Game over. Thanks for playing Knob Wars. |

Generate: `ELEVENLABS_API_KEY=... ./scripts/gen-voice.sh` → `public/voice/<id>.mp3`. Optional;
missing clips fall back to the browser's `speechSynthesis`.

## Join-path fallbacks (for the judging period, not the demo)

1. `cloudflared tunnel --url http://localhost:3000` (tested 2026-09-16: 7 s).
2. Laptop + phones on the iPhone hotspot: `http://<laptop-LAN-IP>:3000`.
3. Nobody joins: fine — the demo never depended on it.

## Honesty line

"Everything running on screen was written during the hour. What I prepared beforehand: the design
docs, installed dependencies, and the announcer voice clips."
