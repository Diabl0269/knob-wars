# Knob Wars — Design

*Decided 2026-09-16, the night before the build. Everything here is a decision, not a question.*

## 1. Pitch (Delight track, with a Breakthrough garnish)

> Everyone in this room has a synthesizer in their pocket. Scan the code. I'll play a sound;
> you rebuild it on your phone. Closest ear wins the round, and every round unlocks more of the synth.

- **Genre**: ear-training game in the spirit of Syntorial (hear a hidden patch, recreate it on a
  built-in synth, lessons unlock controls one at a time) — but multiplayer, timed, with a live
  leaderboard and a big-screen "arena" view.
- **Why judges should care**: audience participation in the demo (they *are* the demo), it sounds
  good on the room speakers, the level ladder is a real pedagogy, and it was built in an hour.
- **Garnish**: "Sensei" hints from Claude Fable 5.1 in musical language ("your sound is brighter and
  snappier than the target — close the filter and lengthen the attack"). Stretch item; cut first.
- **Cross-promo**: the end screen links to https://agentsynth.app ("want the real thing?").

## 2. Modes

| Mode | Where | Network | Notes |
|---|---|---|---|
| **Solo campaign** | `/play` (no room) | none | Levels 1→10, pass at ≥75% accuracy; stars at 75/85/95. Built first: it de-risks the engine and works offline. |
| **Arena** (multiplayer) | host on `/host`, players on `/play?room=CODE` | WebSocket | Host starts a game of N rounds; round r uses level r's control set. Everyone hears the target from the host's speakers; phones may also play locally. |
| **Demo preset** | host page button | — | 3 rounds × 30 s using levels 1, 2, 4. Fits in the 2-minute demo. |

**Round length**: this is a sound-recreation game, not a quiz — players need time to A/B and tweak.
Defaults: arena **6 rounds × 90 s** (host can pick 60/90/120 s and 3–10 rounds in the lobby); solo
is **untimed** (the speed bonus counts down from a 120 s window, then is simply 0). Only the demo
preset is 30 s, because the demo itself is 2 minutes.

## 3. Game loop (one round / one level)

1. **Listen**: target patch plays the fixed phrase (host speakers; phones optionally). Player can
   replay the target any time ("Hear target") and their own ("Hear mine") — A/B is the whole skill.
2. **Tweak**: only this level's unlocked controls are visible; the rest are hidden (not greyed).
3. **Submit** (or the timer expires → auto-submit current patch).
4. **Score** (server in arena, client in solo), reveal target values next to player's, ranking.
5. **Next**: solo → next level if passed; arena → host taps Next (or auto after 8 s).

The phrase is fixed so everybody compares the same notes: eighth-note riff `A3 C4 E4 A4` at 110 BPM,
then `A4` held ~1.2 s (exposes sustain/release), total ≈ 3.3 s. Plus an 8-key strip (A3..A4 white
keys) for free play.

## 4. Patch schema (all numeric params normalized 0..1)

```js
// shared/patch.js
export const DEFAULT_PATCH = {
  wave: "saw",      // "sine" | "triangle" | "saw" | "square"   (categorical; "saw" → Web Audio type "sawtooth")
  cutoff: 1.0,      // 0..1 → 80 Hz .. 12 kHz, log
  res: 0.0,         // 0..1 → Q 0.5 .. 18, linear
  attack: 0.05,     // 0..1 → 2 ms .. 2 s, log
  decay: 0.3,       // 0..1 → 10 ms .. 2 s, log
  sustain: 0.8,     // 0..1 → gain, linear
  release: 0.2,     // 0..1 → 10 ms .. 3 s, log
  lfoRate: 0.3,     // 0..1 → 0.2 .. 20 Hz, log
  lfoPitch: 0.0,    // 0..1 → 0 .. 100 cents vibrato depth
  lfoFilter: 0.0,   // 0..1 → 0 .. 4800 cents (4 octaves) of cutoff modulation
  delayTime: 0.35,  // 0..1 → 0 .. 600 ms
  delayMix: 0.0,    // 0..1 wet level (feedback fixed at 0.4)
  reverbMix: 0.0,   // 0..1 wet level (impulse = 2 s decaying noise, generated once)
  detune: 0.0,      // 0..1 → 0 .. 30 cents on a second oscillator (0 = second osc muted)
};
export const WAVES = ["sine", "triangle", "saw", "square"];
```

Log mapping: `hz = lo * (hi/lo) ** v`. Keep the mapping functions (`toHz`, `toSec`, ...) in
`shared/patch.js` so the engine and the results screen agree on displayed units.

## 5. Level ladder (control unlock order)

| Lvl | Name | Unlocks (cumulative) | Why this order |
|---|---|---|---|
| 1 | Shapes | `wave` | Pure timbre recognition; a 4-way choice anyone can win. |
| 2 | Brightness | `cutoff` | The single most audible continuous control. |
| 3 | Bite | `res` | Hear resonance ring at the cutoff. |
| 4 | Pluck or Pad | `attack`, `release` | Fast vs slow onset/tail — obvious on the held note. |
| 5 | Envelope | `decay`, `sustain` | Completes ADSR. |
| 6 | Vibrato | `lfoRate`, `lfoPitch` | LFO → pitch. |
| 7 | Wobble | `lfoFilter` | LFO → filter (dubstep moment; crowd-pleaser). |
| 8 | Echo | `delayTime`, `delayMix` | First effect. |
| 9 | Space | `reverbMix` | Second effect. |
| 10 | Fat | `detune` | Two-oscillator detune. |

```js
export const LEVELS = [
  { n: 1, name: "Shapes",        unlocks: ["wave"] },
  { n: 2, name: "Brightness",    unlocks: ["cutoff"] },
  { n: 3, name: "Bite",          unlocks: ["res"] },
  { n: 4, name: "Pluck or Pad",  unlocks: ["attack", "release"] },
  { n: 5, name: "Envelope",      unlocks: ["decay", "sustain"] },
  { n: 6, name: "Vibrato",       unlocks: ["lfoRate", "lfoPitch"] },
  { n: 7, name: "Wobble",        unlocks: ["lfoFilter"] },
  { n: 8, name: "Echo",          unlocks: ["delayTime", "delayMix"] },
  { n: 9, name: "Space",         unlocks: ["reverbMix"] },
  { n: 10, name: "Fat",          unlocks: ["detune"] },
];
export const unlockedAt = (n) => LEVELS.slice(0, n).flatMap(l => l.unlocks);
```

**Target generation**: `randomTarget(level, rng)` = `DEFAULT_PATCH` with each *unlocked* param
randomized (wave: uniform over the 4; numeric: uniform in [0.1, 0.9] so extremes don't hide the
control; `lfoPitch`/`lfoFilter`/`delayMix`/`reverbMix`/`detune` in [0.3, 0.9] so the effect is
actually audible). Also ship 2 hand-authored targets per level in `shared/targets.js` with names
("Neon Pluck", "Foghorn") used for the first play-through; random after that. Seeded RNG
(`mulberry32`) so a round's target is reproducible from `roomCode + roundNo`.

## 6. Scoring (one function, `shared/scoring.js`, used by client and server)

```
for each unlocked param p:
  err  = p === "wave" ? (target.wave === mine.wave ? 0 : 1) : |target[p] − mine[p]|   // 0..1
  tol  = p === "wave" ? 1 : 0.35        // off by >35% of the range scores 0 on that control
  s_p  = clamp(1 − err / tol, 0, 1)
accuracy = 100 × mean(s_p)             // equal weights; 0..100
roundPoints = round(accuracy × 10) + speedBonus
speedBonus  = accuracy ≥ 80 ? round(300 × timeLeft / roundSeconds) : 0
```

- Solo: pass at accuracy ≥ 75; stars ★ 75, ★★ 85, ★★★ 95. Campaign score = sum of roundPoints.
- Arena: rank by roundPoints each round; game total = sum. Ties broken by earlier submit time.
- Results screen shows, per unlocked control, target vs mine as two bars (and the real unit, e.g.
  "cutoff: 2.1 kHz vs 800 Hz"). This is the *learning* moment; don't skip it.

## 7. Audio engine (`public/js/engine.js`, Web Audio, no libraries)

```
osc1 (+ osc2 detuned, muted when detune = 0)
  → BiquadFilter (lowpass, freq = toHz(cutoff), Q = toQ(res))
  → amp GainNode (ADSR via setTargetAtTime / linearRampToValueAtTime)
  → [dry] ─────────────────────────────────────────┐
  → DelayNode(delayTime) ⇄ feedback Gain(0.4) → wet Gain(delayMix) ┤
  → ConvolverNode(2 s noise impulse) → wet Gain(reverbMix) ────────┤
                                                                  → master Gain → destination
LFO: OscillatorNode(sine, toHz(lfoRate))
  → Gain(lfoPitch × 100 cents)   → osc1.detune, osc2.detune
  → Gain(lfoFilter × 4800 cents) → filter.detune
```

- `Engine.init()` inside a tap handler; `Engine.playPhrase(patch)`, `Engine.noteOn(patch, midi)`,
  `Engine.noteOff()`. Build a fresh voice graph per note (simplest; no param glitches). Delay and
  reverb stay persistent per engine (shared sends) so tails continue after note-off.
- Master limiter: `DynamicsCompressor` before destination (resonance + square can clip).
- Phones: local audio on by default after the unlock tap; a mute toggle in the header.

## 8. UI

- **Controls**: `<input type="range">` sliders, big (56 px touch height), one per unlocked param,
  label + unit readout. Wave = 4 segmented buttons. Sliders are the floor; rotary knobs are a
  polish item only if Phase 4 has time (pointer-events drag, 40 lines).
- **Player page (`/play`)** — phone portrait, single column, no scrolling in a round:
  header (room, name, level name, timer) → "Hear target" / "Hear mine" buttons → controls →
  key strip → Submit. Results overlay: accuracy, bars, rank, Next.
- **Host page (`/host`)** — projector: left 60% = leaderboard (name, points, last-round accuracy,
  animated re-sort); right 40% = QR + join URL + room code in huge type, then round state
  (level name, countdown ring, "Play target" button, list of who submitted). After the round:
  podium for the round, "Play winner's patch", Next. Lobby: "Start game" / "Demo (3 rounds × 30 s)".
- **Landing (`/`)**: name field, "Solo", "Join room" (code), "Host". Name persisted in localStorage.
- Look & feel: see `docs/VISUAL.md` (neon arcade theme, four waveform accents, oscilloscope, juice
  catalog with per-phase budget). CSS in one file, ≤ 300 lines; canvases in `public/js/fx.js`.
- Responsive: `@media (min-width: 900px)` puts player controls in two columns; the host page
  assumes ≥ 1200 px but must not break at 800.

## 9. Multiplayer protocol (`ws`, JSON, `{ t: "type", ...fields }`)

Rooms live in server memory. Global leaderboard persists to `data/leaderboard.json`.

Client → Server

| `t` | fields | who |
|---|---|---|
| `host:create` | — | host |
| `join` | `room, name` | player (reconnect = same name + `playerId` from localStorage) |
| `host:start` | `rounds` (3–10, default 6), `roundSecs` (60/90/120, default 90) | host |
| `patch` | `patch` | player, on change, throttled to 4/s (server keeps last-known for auto-submit) |
| `submit` | `patch` | player (server ignores after `endsAt`; stamps `submittedAt`) |
| `host:next` | — | host |

The Sensei hint (stretch) is **HTTP** (`POST /api/hint`, §10), not a ws message — one transport decision, already made.

Server → Client

| `t` | fields | to |
|---|---|---|
| `room` | `code, players:[{id,name,total}]` | all in room, on any change |
| `round` | `n, level, unlocked:[...], target, endsAt, roundSecs` | all (phones need `target` to play it locally; cheating via devtools is accepted) |
| `submitted` | `playerId` | all (host shows the tick list) |
| `results` | `n, target, ranking:[{id,name,accuracy,points,total}]` | all |
| `leaderboard` | `top:[{name,total,date}]` | host, after game end |
| `finished` | `ranking` | all |
| `error` | `msg` | requester |

Room state machine: `lobby → round(n) → results(n) → round(n+1) … → finished`.
Server timer: at `endsAt` auto-submit everyone's last-known patch (players stream `patch` on
change, throttled to 4/s, as `{t:"patch", patch}`), compute results, broadcast.
Room codes: 4 uppercase letters, no vowels (avoids words). Rooms expire 30 min after last message.

## 10. Sensei hint (stretch, `/api/hint`)

`POST /api/hint { room, playerId }` → server looks up target + player's last `patch`, calls Claude.
Thinking is always on for `claude-fable-5-1` and its tokens count against `max_tokens`, so the cap must
leave room for it (1024 with `effort: "low"` is plenty; 120 would truncate before any text):

```js
import Anthropic from "@anthropic-ai/sdk";
const client = new Anthropic();               // ANTHROPIC_API_KEY from env
const r = await client.beta.messages.create({
  model: "claude-fable-5-1",
  max_tokens: 1024,
  output_config: { effort: "low" },
  betas: ["server-side-fallback-2026-06-01"],
  fallbacks: [{ model: "claude-opus-4-8" }],
  system: "You are a synth teacher. Compare the player's patch to the target. Reply with ONE sentence of musical, ear-based advice (brighter/darker, snappier/slower, more wobble...). Never state numbers or parameter values. Only mention controls in the unlocked list.",
  messages: [{ role: "user", content: JSON.stringify({ unlocked, target, mine }) }],
});
if (r.stop_reason === "refusal" || r.stop_reason === "max_tokens") return ruleBasedHint(...);
const text = r.content.find(b => b.type === "text")?.text ?? ruleBasedHint(...);
```

Costs ≈ $0.02 per hint. Key comes from `.env` via `node --env-file=.env` (see PREP.md), never from a global export. One hint per round per player, costs 100 points (so it's a choice).
If `ANTHROPIC_API_KEY` is unset the route returns a canned rule-based hint (largest-error control →
"brighter/darker" etc.) — build the rule-based one first; it is the fallback either way.

## 11. Announcer voice

`public/voice/*.mp3` (generated before the event, see `docs/DEMO.md`). `announce(id)` plays the clip
if present, else falls back to `speechSynthesis.speak(line)`. Host page only (phones stay quiet).
Clips: `welcome, round, ten, timeup, levelup, winner, highscore, gameover`.

## 12. File layout

```
server/index.js        http static + ws rooms + /qr + /api/hint        (~250 lines)
shared/patch.js        DEFAULT_PATCH, WAVES, LEVELS, mappings, randomTarget, rng
shared/targets.js      hand-authored named targets, 2 per level
shared/scoring.js      score(target, mine, unlocked, timeLeft, roundSecs)
public/index.html      landing
public/play.html       player + solo
public/host.html       big screen
public/js/engine.js    Web Audio synth + phrase + announcer
public/js/controls.js  slider/segmented rendering from unlocked list
public/js/play.js      solo + arena player logic
public/js/host.js      host logic
public/js/fx.js        oscilloscope, confetti, count-up, FLIP (docs/VISUAL.md)
public/js/net.js       ws client with auto-reconnect
public/css/app.css
public/voice/*.mp3
data/leaderboard.json
```

`server/index.js` serves `/shared/*` from `../shared` so the browser imports the same modules.

## 13. Accepted risks

- Target patch is sent to phones (needed for local playback). Cheating requires devtools; fine.
- No auth, no persistence beyond the global top-20 file, rooms die with the process.
- Venue Wi-Fi: see `docs/DEMO.md` § Fallbacks. Solo mode works offline regardless.
- Resonant square at full cutoff is loud; the compressor + 0.7 master gain covers it.
