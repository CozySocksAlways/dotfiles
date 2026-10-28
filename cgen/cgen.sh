#!/usr/bin/env bash
# cgen: print a raw code snippet to stdout (for vim's  :r !lsnip "...")
[ $# -eq 0 ] && { echo "usage: cgen \"what you want\"" >&2; exit 1; }

claude -p "$*" \
  --model haiku \
  --tools "" \
  --no-session-persistence \
  --setting-sources "" \
  --system-prompt "You are a code snippet generator. Output ONLY the code requested, \
no explanations, no markdown fences, no surrounding prose. Prefer modern idiomatic \
C++ (C++17/20) unless another language is implied. Keep it minimal." \
  2>/dev/null | sed '/^```/d'
