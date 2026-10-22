cask "agent-meter" do
  version "1.0.0"
  sha256 "a763b1469a270d5139c269b6024449ae3871f96ca913a752b0915f30f84ed082"

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
