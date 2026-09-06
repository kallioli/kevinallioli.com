#!/usr/bin/env bash
# Moves the pinned Hugo version and its checksum together.
#
# Renovate deliberately does not manage these two files. The version and the
# checksum of the tarball it names are one unit: a bot can bump the first but
# cannot compute the second, so letting it try produces a tree that fails its
# own verification on every Hugo release. One command is cheaper than a
# permanently red pull request.
#
#   scripts/update-hugo.sh 0.166.0
#
# The tarball is checked against the checksums file published in the same
# release before anything on disk is touched.
set -euo pipefail

version="${1:-}"
[[ -n "$version" ]] || {
  echo "usage: $0 <hugo-version>   (current: $(cat .hugo-version 2>/dev/null || echo unknown))" >&2
  exit 1
}
version="${version#v}"

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

tarball="hugo_extended_${version}_linux-amd64.tar.gz"
checksums="hugo_${version}_checksums.txt"
base="https://github.com/gohugoio/hugo/releases/download/v${version}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "update-hugo: fetching $tarball"
curl -fsSL --output "$tmp/$tarball" "$base/$tarball" ||
  {
    echo "update-hugo: no such release, or no extended linux-amd64 build for v$version" >&2
    exit 1
  }
curl -fsSL --output "$tmp/$checksums" "$base/$checksums" ||
  {
    echo "update-hugo: release v$version publishes no $checksums" >&2
    exit 1
  }

echo "update-hugo: verifying against the checksums published in the release"
line=$(grep -F " $tarball" "$tmp/$checksums" || true)
[[ -n "$line" ]] || {
  echo "update-hugo: $tarball is not listed in $checksums" >&2
  exit 1
}
(cd "$tmp" && printf '%s\n' "$line" | sha256sum --check --status) ||
  {
    echo "update-hugo: checksum mismatch, refusing to pin $version" >&2
    exit 1
  }

printf '%s\n' "$version" >.hugo-version
printf '%s\n' "$line" >.hugo-sha256

echo "update-hugo: pinned $version"
echo
echo "Next: install it locally, then rebuild."
echo "  tar -xzf <tarball> hugo && install -m755 hugo ~/.local/bin/hugo"
echo "  make check"
