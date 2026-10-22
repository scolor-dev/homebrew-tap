# homebrew-tap

Homebrew tap for [Agent Meter](https://github.com/scolor-dev/agent-meter), a macOS menu bar app that shows Codex and Claude Code usage limits.

```sh
brew install --cask scolor-dev/tap/agent-meter
```

To update, use Agent Meter's built-in updater, or:

```sh
brew upgrade --cask --greedy agent-meter
```

## How the cask is kept current

The `Update cask` workflow runs hourly (and on demand from the Actions tab). It looks up the latest stable release of `scolor-dev/agent-meter`, downloads the ZIP, and only publishes it when the app is signed by the expected Developer ID team and accepted by Gatekeeper (that is, notarized). It then rewrites `Casks/agent-meter.rb` and commits the change. No secrets are involved: the workflow only reads public releases and pushes to this repository with its own token.

GitHub disables scheduled workflows after 60 days without repository activity; if updates stop, re-enable the workflow in the Actions tab.
