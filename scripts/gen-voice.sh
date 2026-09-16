#!/usr/bin/env bash
# Generate announcer clips with ElevenLabs into public/voice/<id>.mp3.
# Usage: ELEVENLABS_API_KEY=... [ELEVENLABS_VOICE_ID=...] ./scripts/gen-voice.sh
# The key is read from the environment only; it is never printed or written to disk.
set -euo pipefail
: "${ELEVENLABS_API_KEY:?set ELEVENLABS_API_KEY in the environment}"
VOICE="${ELEVENLABS_VOICE_ID:-21m00Tcm4TlvDq8ikWAM}"   # ElevenLabs premade voice "Rachel"; override to taste
MODEL="${ELEVENLABS_MODEL_ID:-eleven_multilingual_v2}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/public/voice"
mkdir -p "$OUT"

lines=(
  "welcome|Welcome to Knob Wars. Scan the code, grab a synth, and get ready."
  "round|New round. Listen closely."
  "ten|Ten seconds."
  "timeup|Time's up! Let's see the scores."
  "levelup|Level up! New controls unlocked."
  "winner|We have a winner!"
  "highscore|New high score!"
  "gameover|Game over. Thanks for playing Knob Wars."
)

for entry in "${lines[@]}"; do
  id="${entry%%|*}"; text="${entry#*|}"
  printf 'generating %-10s ' "$id"
  body=$(python3 -c 'import json,sys; print(json.dumps({"text": sys.argv[1], "model_id": sys.argv[2]}))' "$text" "$MODEL")
  code=$(curl -sS -o "$OUT/$id.mp3" -w '%{http_code}' \
    -H "xi-api-key: $ELEVENLABS_API_KEY" -H "Content-Type: application/json" -H "Accept: audio/mpeg" \
    -d "$body" "https://api.elevenlabs.io/v1/text-to-speech/$VOICE")
  if [ "$code" != "200" ]; then echo "FAILED (HTTP $code)"; cat "$OUT/$id.mp3"; echo; rm -f "$OUT/$id.mp3"; exit 1; fi
  echo "ok ($(du -h "$OUT/$id.mp3" | cut -f1))"
done
echo "done → $OUT (the game falls back to speechSynthesis for any missing clip)"
