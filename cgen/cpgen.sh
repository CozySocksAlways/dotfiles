#!/usr/bin/env bash
# cpgen: rewrite the last visual selection per a prompt, print raw code to stdout
# (for vim's  :r !cpgen "..."). nvim side (lua/cpgen) exports CPGEN_SEL/CPGEN_FT.
[ $# -eq 0 ] && { echo "usage: cpgen \"what to do with the selection\"" >&2; exit 1; }

sel=""
[ -n "$CPGEN_SEL" ] && [ -r "$CPGEN_SEL" ] && sel=$(cat "$CPGEN_SEL")
[ -z "$sel" ] && { echo "cpgen: no visual selection recorded" >&2; exit 1; }

{
  printf 'Instruction: %s\n\n' "$*"
  printf 'Code (%s):\n%s\n' "${CPGEN_FT:-unknown language}" "$sel"
} | claude -p \
  --model haiku \
  --tools "" \
  --no-session-persistence \
  --setting-sources "" \
  --system-prompt "You are a code transformer. You receive an instruction and a code \
snippet. Output ONLY the resulting code, no explanations, no markdown fences, no \
surrounding prose. Keep the snippet's language and indentation style. Keep it minimal." \
  2>/dev/null | sed '/^```/d'
