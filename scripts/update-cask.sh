#!/usr/bin/env bash
# Regenerate Casks/audify.rb from the live appcast feeds.
#
# Run this after every release. It reads the published version, streams both DMGs to
# compute their checksums (nothing is written to disk), and rewrites the cask in place.
#
#   ./scripts/update-cask.sh          # update the cask
#   ./scripts/update-cask.sh --commit # update, then commit the change
#
set -euo pipefail

BASE="https://download.audifyplayer.com"
ARM_FEED="$BASE/appcast.json"
INTEL_FEED="$BASE/appcast-macos-x64.json"
CASK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/Casks/audify.rb"

json_field() { # url, field
  curl -fsSL --max-time 30 "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}

sha_of() { # url — streams, never lands on disk
  echo "  fetching $(basename "$1")" >&2
  curl -fsSL --max-time 900 "$1" | shasum -a 256 | awk '{print $1}'
}

ARM_VERSION="$(json_field "$ARM_FEED" version)"
INTEL_VERSION="$(json_field "$INTEL_FEED" version)"
ARM_URL="$(json_field "$ARM_FEED" url)"
INTEL_URL="$(json_field "$INTEL_FEED" url)"

[ -n "$ARM_VERSION" ] || { echo "could not read version from $ARM_FEED" >&2; exit 1; }

# A cask carries one version for both architectures. If the feeds ever drift apart the
# cask would ship a checksum that does not match the URL it builds, so stop here instead.
if [ "$ARM_VERSION" != "$INTEL_VERSION" ]; then
  echo "feeds disagree: arm=$ARM_VERSION intel=$INTEL_VERSION — publish both, then rerun" >&2
  exit 1
fi

echo "Audify $ARM_VERSION — computing checksums (about 220 MB, not saved)"
ARM_SHA="$(sha_of "$ARM_URL")"
INTEL_SHA="$(sha_of "$INTEL_URL")"

# Rewrite only the three generated lines; everything else in the cask is hand-maintained.
/usr/bin/sed -i '' \
  -e "s|^  version \".*\"|  version \"$ARM_VERSION\"|" \
  -e "s|^  sha256 arm:   \".*\"|  sha256 arm:   \"$ARM_SHA\"|" \
  -e "s|^         intel: \".*\"|         intel: \"$INTEL_SHA\"|" \
  "$CASK"

echo "updated $CASK"
echo "  version $ARM_VERSION"
echo "  arm     $ARM_SHA"
echo "  intel   $INTEL_SHA"

# brew audit only accepts a cask *name*, never a path, and the name only resolves once the
# tap is installed. Skip cleanly when it is not rather than failing the release step.
TAP="${AUDIFY_TAP:-ashishkp010/tap}"
if command -v brew >/dev/null 2>&1 && brew tap | grep -qx "$TAP"; then
  echo
  echo "Validating $TAP/audify..."
  brew audit --cask --online "$TAP/audify" || echo "(audit reported issues — review before pushing)"
else
  echo
  echo "Skipping audit — tap '$TAP' is not installed locally."
  echo "After pushing, validate with: brew tap $TAP && brew audit --cask --online $TAP/audify"
fi

if [ "${1:-}" = "--commit" ]; then
  git -C "$(dirname "$CASK")/.." add Casks/audify.rb
  git -C "$(dirname "$CASK")/.." commit -m "audify $ARM_VERSION"
  echo "committed — run 'git push' when ready"
fi
