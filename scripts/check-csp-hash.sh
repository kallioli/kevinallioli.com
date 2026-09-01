#!/usr/bin/env bash
# Verifies that the CSP script-src hash published in public/_headers really
# matches the inline script served in the built HTML. The hash is computed
# by Hugo from the source resource; HTML minification happens afterwards, so
# this check is what proves the two did not drift.
set -euo pipefail

root="${1:-public}"
headers="$root/_headers"

[[ -f "$headers" ]] || {
  echo "check-csp-hash: $headers not found" >&2
  exit 1
}

declared=$(grep -o "'sha256-[A-Za-z0-9+/=]\+'" "$headers" | head -1 | tr -d "'")
[[ -n "$declared" ]] || {
  echo "check-csp-hash: no sha256 hash in $headers" >&2
  exit 1
}

fail=0
count=0
while IFS= read -r -d '' page; do
  # Extract every inline <script> without a src attribute.
  mapfile -t actual < <(
    python3 - "$page" <<'PY'
import re, sys, hashlib, base64
html = open(sys.argv[1], encoding="utf-8").read()
for m in re.finditer(r"<script(?![^>]*\bsrc=)([^>]*)>(.*?)</script>", html, re.S):
    attrs, body = m.group(1), m.group(2)
    if "application/ld+json" in attrs:
        continue          # data block, not executed, not covered by script-src
    digest = hashlib.sha256(body.encode("utf-8")).digest()
    print("sha256-" + base64.b64encode(digest).decode())
PY
  )
  for h in "${actual[@]:-}"; do
    [[ -z "$h" ]] && continue
    count=$((count + 1))
    if [[ "$h" != "$declared" ]]; then
      echo "check-csp-hash: ${page}: inline script hash $h is not allowed by the CSP" >&2
      fail=1
    fi
  done
done < <(find "$root" -name '*.html' -print0)

if ((fail)); then exit 1; fi
if ((count == 0)); then
  echo "check-csp-hash: no inline script found; the CSP hash is stale" >&2
  exit 1
fi
echo "check-csp-hash: ok, $count inline scripts all match $declared"
