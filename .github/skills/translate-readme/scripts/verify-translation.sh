#!/usr/bin/env bash
# verify-translation.sh
# Verify that a translated README preserves the structural / technical
# content of its source README byte-for-byte.
#
# Checks performed:
#   1. Fenced code blocks (``` ... ```) are byte-identical and in the same order.
#   2. Image markdown paths (the URL inside ![alt](url)) are byte-identical
#      and in the same order. (Alt text MAY differ — it is allowed to be
#      translated.)
#   3. Inline code spans (`like this`) are byte-identical and in the same order.
#   4. Hyperlink URLs ([text](url)) are byte-identical and in the same order.
#      (Link display text MAY differ.)
#
# Usage:
#   bash verify-translation.sh <source.md> <translated.md> [--before "## Heading"]
#
# The optional --before flag truncates the source file at the given heading
# (exclusive) before comparing. Use this when the translation covers only the
# content before a boundary heading (e.g. --before "## Demo" for the default
# preamble-only scope of the translate-readme skill).
#
# Exit codes:
#   0 = all checks passed
#   1 = at least one check failed
#   2 = invalid arguments / missing files

set -u

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <source.md> <translated.md> [--before \"## Heading\"]" >&2
  exit 2
fi

SRC="$1"
DST="$2"
BOUNDARY=""
shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --before)
      BOUNDARY="${2:-}"
      if [[ -z "$BOUNDARY" ]]; then
        echo "ERROR: --before requires a heading argument" >&2
        exit 2
      fi
      shift 2
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: source file not found: $SRC" >&2
  exit 2
fi
if [[ ! -f "$DST" ]]; then
  echo "ERROR: translated file not found: $DST" >&2
  exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# Normalise line endings (CRLF -> LF) so files saved on Windows compare cleanly.
normalise() {
  sed 's/\r$//' "$1"
}

SRC_LF="$TMPDIR/src.lf"
DST_LF="$TMPDIR/dst.lf"
normalise "$SRC" > "$SRC_LF"
normalise "$DST" > "$DST_LF"

# If a boundary heading is supplied, materialise a truncated copy of the
# source that contains only the content BEFORE that heading. Otherwise use
# the (normalised) source file as-is.
SRC_EFFECTIVE="$SRC_LF"
if [[ -n "$BOUNDARY" ]]; then
  SRC_EFFECTIVE="$TMPDIR/src.truncated.md"
  awk -v boundary="$BOUNDARY" '
    $0 == boundary { exit }
    { print }
  ' "$SRC_LF" > "$SRC_EFFECTIVE"
  if ! grep -qxF "$BOUNDARY" "$SRC_LF"; then
    echo "WARN: boundary heading not found in source: $BOUNDARY" >&2
  fi
fi
DST_EFFECTIVE="$DST_LF"

extract_fences() {
  # Print every fenced block (including fences) as null-separated records.
  awk '
    /^[[:space:]]*```/ {
      if (in_block) {
        print buf "```"
        printf "\0"
        buf=""
        in_block=0
        next
      } else {
        in_block=1
        buf=$0 "\n"
        next
      }
    }
    {
      if (in_block) buf=buf $0 "\n"
    }
  ' "$1"
}

extract_image_urls() {
  # Match ![alt](url) and print only url, in document order.
  grep -oE '!\[[^]]*\]\([^)]+\)' "$1" \
    | sed -E 's/^!\[[^]]*\]\(([^)]+)\)$/\1/'
}

extract_link_urls() {
  # Match [text](url) but NOT ![alt](url). Print only url, in document order.
  # We strip image syntax first, then match plain links.
  sed -E 's/!\[[^]]*\]\([^)]+\)//g' "$1" \
    | grep -oE '\[[^]]+\]\([^)]+\)' \
    | sed -E 's/^\[[^]]+\]\(([^)]+)\)$/\1/'
}

extract_inline_code() {
  # Strip fenced blocks first so inline backticks inside fences don't leak.
  awk '
    /^[[:space:]]*```/ { in_block = !in_block; next }
    !in_block { print }
  ' "$1" \
    | grep -oE '`[^`]+`'
}

FAIL=0

check_diff() {
  local label="$1"
  local a="$2"
  local b="$3"
  if ! diff -u --text "$a" "$b" > "$TMPDIR/diff.out"; then
    echo "FAIL: $label differ between source and translated file:"
    sed 's/^/    /' "$TMPDIR/diff.out"
    FAIL=1
  else
    echo "OK:   $label match"
  fi
}

extract_fences        "$SRC_EFFECTIVE" > "$TMPDIR/src.fences"
extract_fences        "$DST_EFFECTIVE" > "$TMPDIR/dst.fences"
extract_image_urls    "$SRC_EFFECTIVE" > "$TMPDIR/src.images"
extract_image_urls    "$DST_EFFECTIVE" > "$TMPDIR/dst.images"
extract_link_urls     "$SRC_EFFECTIVE" > "$TMPDIR/src.links"
extract_link_urls     "$DST_EFFECTIVE" > "$TMPDIR/dst.links"
extract_inline_code   "$SRC_EFFECTIVE" > "$TMPDIR/src.inline"
extract_inline_code   "$DST_EFFECTIVE" > "$TMPDIR/dst.inline"

check_diff "fenced code blocks" "$TMPDIR/src.fences" "$TMPDIR/dst.fences"
check_diff "image URLs"          "$TMPDIR/src.images" "$TMPDIR/dst.images"
check_diff "hyperlink URLs"      "$TMPDIR/src.links"  "$TMPDIR/dst.links"
check_diff "inline code spans"   "$TMPDIR/src.inline" "$TMPDIR/dst.inline"

if [[ $FAIL -ne 0 ]]; then
  echo
  echo "Translation verification FAILED: $DST has structural drift from $SRC."
  exit 1
fi

echo
echo "Translation verification PASSED."
exit 0
