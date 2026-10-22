cask "agent-meter" do
  version "1.0.1"
  sha256 "6f363b865c0b12e2f892c77639232fda9dc5d88b2197a188135ba62e31c9dee2"

  url "https://github.com/scolor-dev/agent-meter/releases/download/v#{version}/AgentMeter-#{version}.zip"
  name "Agent Meter"
  desc "Menu bar meter for Codex and Claude Code usage limits"
  homepage "https://github.com/scolor-dev/agent-meter"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app updates itself with Sparkle; `brew upgrade --greedy` also works.
  auto_updates true
  depends_on macos: :sonoma

  app "AgentMeter.app"

  zap trash: [
    "~/Library/Caches/dev.scolor.AgentMeter",
    "~/Library/HTTPStorages/dev.scolor.AgentMeter",
    "~/Library/Preferences/dev.scolor.AgentMeter.plist",
  ]
end
