#!/usr/bin/env bash
# Rewrites Casks/agent-meter.rb for a stable scolor-dev/agent-meter release.
#
# Usage: scripts/update-cask.sh [TAG]
#
# Without TAG, the latest stable (non-draft, non-prerelease) release is used. Nothing is changed
# unless the release is newer than the cask, and an app that is not signed by the expected team
# or not notarized is refused so it never reaches Homebrew users.
#
# Test hook: ZIP_PATH=/path/to/AgentMeter-x.y.z.zip skips the download.
set -euo pipefail

REPO="scolor-dev/agent-meter"
TEAM_ID="Z8BT88C36P"
CASK="Casks/agent-meter.rb"

cd "$(dirname "$0")/.."

tag="${1:-}"
if [[ -z "$tag" ]]; then
  # A 404 simply means there is no stable release yet, which is not an error.
  if ! tag="$(gh api "repos/$REPO/releases/latest" --jq .tag_name 2>/dev/null)"; then
    tag=""
  fi
  if [[ -z "$tag" ]]; then
    echo "No stable release of $REPO yet; nothing to do."
    exit 0
  fi
fi
if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Refusing unexpected tag: $tag" >&2
  exit 1
fi
version="${tag#v}"

current=""
if [[ -f "$CASK" ]]; then
  current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK" | head -1)"
fi
if [[ -n "$current" ]]; then
  newest="$(printf '%s\n%s\n' "$current" "$version" | sort -V | tail -1)"
  if [[ "$version" == "$current" || "$newest" != "$version" ]]; then
    echo "Cask is already at $current; nothing to do for $version."
    exit 0
  fi
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
zip="$work/AgentMeter-$version.zip"
if [[ -n "${ZIP_PATH:-}" ]]; then
  cp "$ZIP_PATH" "$zip"
else
  curl -fsSL -o "$zip" "https://github.com/$REPO/releases/download/$tag/AgentMeter-$version.zip"
fi

ditto -x -k "$zip" "$work/unzipped"
app="$work/unzipped/AgentMeter.app"
if [[ ! -d "$app" ]]; then
  echo "AgentMeter.app is missing from the archive." >&2
  exit 1
fi

signature="$(codesign -dvv "$app" 2>&1)"
if ! grep -q "^TeamIdentifier=$TEAM_ID$" <<<"$signature"; then
  echo "The app is not signed by team $TEAM_ID." >&2
  exit 1
fi
codesign --verify --deep --strict "$app"

if ! spctl --assess --type execute "$app" 2>/dev/null; then
  echo "Gatekeeper does not accept the app (not notarized?). Not publishing $version to Homebrew." >&2
  exit 1
fi

sha256="$(shasum -a 256 "$zip" | awk '{print $1}')"

cat > "$CASK" <<RUBY
cask "agent-meter" do
  version "$version"
  sha256 "$sha256"

  url "https://github.com/$REPO/releases/download/v#{version}/AgentMeter-#{version}.zip"
  name "Agent Meter"
  desc "Menu bar meter for Codex and Claude Code usage limits"
  homepage "https://github.com/$REPO"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app updates itself with Sparkle; \`brew upgrade --greedy\` also works.
  auto_updates true
  depends_on macos: :sonoma

  app "AgentMeter.app"

  zap trash: [
    "~/Library/Caches/dev.scolor.AgentMeter",
    "~/Library/HTTPStorages/dev.scolor.AgentMeter",
    "~/Library/Preferences/dev.scolor.AgentMeter.plist",
  ]
end
RUBY

echo "Updated $CASK to $version ($sha256)."
