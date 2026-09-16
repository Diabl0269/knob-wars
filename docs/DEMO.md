# Knob Wars — 2-minute demo script

Setup before you're called: `/host` fullscreen on the projector, room created, QR visible, laptop
audio to the room speakers (or the Bluetooth speaker), phone in hand joined as "Tal", volume up.
Say the honesty line if asked (bottom).

| Time | Say | Do |
|---|---|---|
| 0:00 | "Everyone in this room has a synthesizer in their pocket. Scan this." | Point at the QR. Wait ~10 s while names pop onto the leaderboard. |
| 0:15 | "Knob Wars: I play a sound, you rebuild it by ear on your phone. Closest ear wins. Every round unlocks more of the synth." | Tap **Demo** (3 rounds × 30 s). Announcer: "Round one. Listen closely." |
| 0:25 | *(silence — let the target play twice)* "Round one is just the waveform. Four shapes. Pick the one you hear." | Tap **Play target** once more. Show your phone: tap a wave, Submit. |
| 0:50 | "Time's up." | Announcer says it. Results: podium + leaderboard. Read the top name aloud. |
| 1:00 | "Round two unlocks the filter. Now it's about brightness." | Round 2 starts; play target; show the cutoff slider on your phone; move it while a note holds. |
| 1:25 | "Round three: envelope. Pluck or pad?" | Round 3; if the Sensei hint landed: tap **Hint** on your phone and read Claude's one-liner aloud. |
| 1:45 | "Final leaderboard." | Announcer: "We have a winner!" Read the winner. |
| 1:55 | "Solo mode has ten levels — filter, resonance, envelopes, LFOs, delay, reverb. All of this was built in the last hour with Fable 5.1. It links to AgentSynth, the real synth I'm building." | Show the finish screen with the link. Done. |

Rules for the room: keep it moving — never wait for stragglers; the timer does the pacing.
If the tunnel dies mid-demo: "Wi-Fi's out — solo mode works offline" and play a level on the phone
held to the mic. Not great, still a demo.

## Announcer lines (ElevenLabs, generated before the event)

| id | line |
|---|---|
| welcome | Welcome to Knob Wars. Scan the code, grab a synth, and get ready. |
| round | New round. Listen closely. |
| ten | Ten seconds. |
| timeup | Time's up! Let's see the scores. |
| levelup | Level up! New controls unlocked. |
| winner | We have a winner! |
| highscore | New high score! |
| gameover | Game over. Thanks for playing Knob Wars. |

Generate: `ELEVENLABS_API_KEY=... ./scripts/gen-voice.sh` → `public/voice/<id>.mp3`. The script
reads `ELEVENLABS_VOICE_ID` (default is a premade ElevenLabs voice id; pick your favourite from
the ElevenLabs voice library and override). If no clips exist the game falls back to the browser's
`speechSynthesis`, so this is nice-to-have, not blocking.

Optional flourish: a 10-second "trailer" for the opening — not worth the time; the live room is
the trailer.

## Fallbacks for the join path, in order

1. `cloudflared tunnel --url http://localhost:3000` (no account; started at 19:00, tested in PREP).
2. Laptop and phones on the **iPhone hotspot**; join `http://<laptop-LAN-IP>:3000` (QR encodes that URL when `PUBLIC_URL` env var is set to it).
3. Two browser windows on the laptop (host + one player) and Solo on the phone.

## Honesty line

"Everything running on screen was written during the hour. What I prepared beforehand: the design
doc and plan, installed dependencies, and the announcer voice clips."
