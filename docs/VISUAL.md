# Knob Wars — Visual & game-feel spec

*It's a game. It has to look spectacular on a projector and feel alive on a phone — within the
hour.* Everything below is CSS transforms/opacity or a ≤40-line canvas; no libraries, no CDNs,
no images. Each item has a cost so the build session can spend by the cut list.

## 1. Art direction: "neon arcade synth"

- **Background** `#0b0f1f` (deep navy), surfaces `#141a33`, text `#f4f6ff`, muted `#8a93b8`.
- **Four accents = the four waveforms**, used as the whole game's colour language:
  sine **cyan `#2ee6ff`**, triangle **lime `#a8ff3e`**, saw **magenta `#ff3ea5`**, square **orange `#ffb02e`**.
  Each level takes the accent of its index (`level % 4`) for the timer, the "NEW" tags and the glow,
  so every round *looks* different without any extra design.
- **Type**: system font stack at weight 900 for headings/numbers (`font-family: system-ui, -apple-system,
  "Segoe UI", Roboto, sans-serif; font-weight: 900; letter-spacing: -0.02em`), `font-variant-numeric:
  tabular-nums` on the timer and scores. Host headline sizes: room code 9rem, timer 7rem, leaderboard
  names 2.2rem — legible from the back of the room.
- **Glow**: one reusable `.glow { box-shadow: 0 0 24px var(--accent), 0 0 64px color-mix(in srgb, var(--accent) 40%, transparent) }`.
- **Living background**: two blurred radial-gradient blobs (`filter: blur(80px)`) drifting on a 20 s
  `@keyframes` loop, plus a faint 40 px grid. `position: fixed`, `z-index: -1`, 12 lines of CSS.
- **Waveform icons**: the four wave buttons show a 48×24 inline SVG of the shape (sine curve,
  triangle, saw teeth, square). Instantly readable, no words needed.
- **Oscilloscope** (the signature visual): an `AnalyserNode` on the master bus draws the live waveform
  on a `<canvas>` — full-width hero strip on the host page (accent-coloured line, glow via
  `shadowBlur`), 56 px strip under the header on the phone. ~30 lines, 30 fps on phone
  (`requestAnimationFrame` with a frame skip). When the target plays, the line is the level accent;
  when the player's own patch plays, it's white — so "hear target / hear mine" is visible too.

## 2. Juice catalog (what happens when things happen)

| # | Moment | Effect | How | Cost |
|---|---|---|---|---|
| 1 | Any button press | scale 0.96 on `:active`, springs back (`transition: transform 120ms cubic-bezier(.2,1.6,.4,1)`) | CSS | 1 min |
| 2 | Slider moves | thumb glows in the accent; a value pill above the thumb pops (scale 1.15→1) and shows the real unit ("2.1 kHz") | CSS + 8 lines JS | 4 min |
| 3 | Round timer | SVG ring, `stroke-dashoffset` driven by the clock; under 5 s it turns red and pulses; host page edges glow red | SVG + CSS | 5 min |
| 4 | Player joins | name chip with a random synth avatar (🎛️ 🎚️ 🎹 🔊 🎧 🌊 ⚡ 🪩) pops in on the host (scale 0→1 overshoot) | CSS keyframes | 3 min |
| 5 | Player submits | their chip gets a ✓ and a quick flash; host shows "7/12 in" | CSS | 2 min |
| 6 | Time's up | 300 ms screen shake (`translate` ±3 px keyframes) on host, announcer clip | CSS | 2 min |
| 7 | Score reveal (phone) | points count up 0→N over 900 ms ease-out, huge tabular digits; "+300 SPEED" label flies up and fades if bonus | rAF, 15 lines | 4 min |
| 8 | Accuracy bars | target vs mine bars sweep in (`width` transition 600 ms), staggered 80 ms per control; ≥90% controls get a ✨ | CSS + stagger | 4 min |
| 9 | Leaderboard re-sort (host) | FLIP: record `getBoundingClientRect`, reorder DOM, apply inverse `transform`, transition 600 ms. Top row gold glow, 🥇🥈🥉 medals | 25 lines JS | 6 min |
| 10 | Round winner / game over | confetti burst: canvas, 150 particles in the four accents, gravity, 1.5 s | 40 lines JS | 6 min |
| 11 | Level up | the new control card slides in from the right with a pulsing "NEW" tag in the level accent; the level name stamps in (scale 1.4→1, 300 ms) | CSS | 4 min |
| 12 | Streak | 2+ rounds ≥80% shows 🔥×n next to the name | 5 lines | 2 min |

Rules: animate only `transform`/`opacity`/`stroke-dashoffset` (never layout); every effect ≤ 1 s
except the ring; honour `@media (prefers-reduced-motion: reduce)` by collapsing durations to 0.

## 3. Screens (what "beautiful" means per page)

- **Host / big screen**: hero oscilloscope across the top; left = leaderboard cards (avatar, name,
  points, last-round accuracy bar); right = QR on a white rounded card with the room code in 9rem
  accent type, then the timer ring with the level name inside it. Between rounds the podium takes
  the whole right side. Everything is readable at 10 m.
- **Phone / player**: one column, no scrolling in a round. Header (level name in accent, timer
  pill), mini oscilloscope, two big pill buttons "▶ Target" / "▶ Mine", control cards (each a
  rounded card with the icon/slider/pill), 8-key strip, full-width Submit in the accent. Results
  overlay slides up from the bottom (sheet), count-up score, bars, rank, Next.
- **Landing**: title in the four accents (one letter group per colour), pulsing "Tap to start"
  (also the audio unlock), name field, three big buttons.

## 4. Where it lands in the timeline (and the visual cut list)

| Phase | Included | Minutes |
|---|---|---|
| 1 | Theme tokens, type, wave icons, button press (#1), slider pill (#2), phone layout | ~6 |
| 2 | Timer ring (#3), join pops (#4), submit ticks (#5), host layout | ~7 |
| 3 | Oscilloscope, count-up (#7), bars sweep (#8), FLIP leaderboard (#9), confetti (#10), level-up reveal (#11), time's-up shake (#6) | ~14 (this is Phase 3's main job) |
| 4 | Living background, streaks (#12), medals polish | if time |

Visual cut order (cut from the top): living background → streaks → shake → FLIP (fall back to an
instant re-sort with a fade) → level-up slide → confetti. **Never cut**: theme, wave icons, timer
ring, count-up, bars, oscilloscope — those six are what makes it look like a game on the projector.

## 5. Why these (research notes)

Party games that work on a big screen + phones (Kahoot, Jackbox) keep the phone controller to a
handful of huge components and put all the spectacle — leaderboard, timer, reveals — on the shared
screen; synchronized timers and instant "X submitted" feedback are what keep a room engaged.
"Juice" (Jonasson & Purho) is bountiful feedback for small inputs: tweening, scale/squash, screen
shake (small and dampened), particles and sound at every meaningful moment — it's mechanically
superfluous but it's what makes the same game feel alive.

## 6. All ages (Clash Royale rule: a kid and an adult must both want to play)

What Supercell does that we can copy for free: bright saturated colours with strong contrast, chunky
rounded shapes with distinctive silhouettes, one colour reserved for *the* action button, characters
with no detail on calm backgrounds, and progression you can read without reading. Concrete rules:

- **No jargon on screen before it's unlocked.** Level names and control labels are plain words:
  "Shape", "Brightness", "Bite", "Pluck or Pad", "Wobble", "Echo", "Space", "Fat". The technical
  name appears small underneath ("cutoff", "Q") so adults learn the real terms. Tooltips: none.
- **Understandable without reading**: the loop is three icons on the landing card — 👂 Listen →
  🎛️ Match → 🚀 Submit — and the first level is a 4-way picture choice (the wave icons) that a
  seven-year-old can win.
- **One action colour.** Submit / Start / Next are always the same warm yellow-orange (`#ffb02e`);
  nothing else is that colour. Secondary buttons are outlined.
- **Chunky**: 16 px corner radius on cards, 999 px on buttons, 56 px minimum touch height, 4 px
  bottom "edge" on primary buttons (`box-shadow: 0 4px 0 #b8760f`) that disappears on press — the
  classic pressable-toy look.
- **Characters**: each player picks a synth-creature avatar (🎛️ 🎚️ 🎹 🔊 🎧 🌊 ⚡ 🪩 🐙 🦄 🤖 👾) at join;
  it appears on the host leaderboard at 2rem and reacts: bounce on submit, shake on 0 points,
  crown 👑 on the leader. Zero art cost, instant personality.
- **Rewards you can see**: stars ★★★ per solo level, trophies 🏆 for arena wins, a level-unlock
  card that flips open like a chest ("NEW: Brightness"), and the score count-up with the flying
  "+300 SPEED". Progress bar of levels 1–10 on the solo screen; earned stars stay lit.
- **Never shame**: below 75% says "Close! Listen again" with a replay button, never "FAIL"; the
  accuracy bars show *how* close, which is the lesson. Adults get the same screen plus the real units.
- **Short sessions**: a solo level is ~1 minute, an arena game is 6–9 minutes, and the demo is 2.
- **Safe for a room with kids**: no chat, no free-text beyond a 12-character name, avatars from a
  fixed set; the host can kick a name from the lobby.
