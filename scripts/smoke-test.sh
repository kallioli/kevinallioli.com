#!/usr/bin/env bash
# Asserts that a deployed site really serves what this repository built:
# the apex answers, `_headers` is in force, the CSP carries the hash of the
# script that was just built, and www redirects to the apex keeping the path.
#
# Run against production after a deploy, or against any origin:
#   scripts/smoke-test.sh [BASE_URL] [WWW_URL] [HEADERS_FILE]
set -euo pipefail

base="${1:-https://kevinallioli.com}"
www="${2:-https://www.kevinallioli.com}"
headers_file="${3:-public/_headers}"
base="${base%/}"
www="${www%/}"

fail() {
  echo "smoke-test: $*" >&2
  exit 1
}

[[ -f "$headers_file" ]] || fail "$headers_file not found; run a build first"

# The asset server needs a moment to pick up a fresh deployment.
code=""
for attempt in 1 2 3 4 5; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' "$base/" || echo 000)
  if [[ "$code" == "200" ]]; then
    break
  fi
  echo "smoke-test: attempt ${attempt}, apex answered ${code}"
  sleep 6
done
[[ "$code" == "200" ]] || fail "apex never answered 200, last was $code"

served=$(curl -sSI "$base/" | tr -d '\r')

grep -qi '^strict-transport-security:' <<<"$served" ||
  fail "no HSTS header: _headers is not being applied"

csp=$(grep -i '^content-security-policy:' <<<"$served") ||
  fail "no CSP header: _headers is not being applied"

# The whole point of generating _headers: what is served must carry the hash
# of the script this build produced, not of some earlier one.
built_hash=$(grep -o "'sha256-[A-Za-z0-9+/=]\+'" "$headers_file" | head -1 | tr -d "'")
[[ -n "$built_hash" ]] || fail "no script hash in $headers_file"
grep -qF "$built_hash" <<<"$csp" ||
  fail "the served CSP does not carry the built script hash $built_hash"

# The www redirect is a zone rule, not something this repository can deploy.
# See docs/dns.md; a failure here means the rule is missing or wrong.
location=$(curl -sSI "$www/articles/" | tr -d '\r' | sed -n 's/^[Ll]ocation: //p')
[[ "$location" == "$base/articles/" ]] ||
  fail "www redirect: expected $base/articles/, got '${location:-nothing}' (see docs/dns.md)"

feed=$(curl -sS "$base/index.xml" | head -c 5)
[[ "$feed" == "<?xml" ]] || fail "the feed at $base/index.xml is not XML"

echo "smoke-test: ok, $base serves the built headers and www redirects to it"
