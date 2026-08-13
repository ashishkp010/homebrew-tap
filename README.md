# Audify Homebrew Tap

Install [Audify](https://audifyplayer.com) — a free music and video player for your local
library — on macOS:

```sh
brew install --cask ashishkp010/tap/audify
```

Or tap first, then install by short name:

```sh
brew tap ashishkp010/tap
brew install --cask audify
```

Upgrade along with everything else:

```sh
brew upgrade --cask audify
```

Uninstall, including settings and cached artwork:

```sh
brew uninstall --zap --cask audify
```

Apple Silicon and Intel Macs both work — Homebrew picks the matching build automatically.

## Releasing a new version

This tap is a separate **public** repository from the app source. After publishing a
release to `download.audifyplayer.com` and updating the appcast feeds, run:

```sh
./scripts/update-cask.sh --commit
```

It reads the live version from the appcast, streams both DMGs to compute their SHA-256
checksums, rewrites `Casks/audify.rb`, runs `brew audit`, and commits. Then `git push`.

The script refuses to run if the Apple Silicon and Intel feeds report different versions,
since a cask carries a single version for both architectures.

## Repository setup

This directory is the *contents* of the tap, not the tap itself. Homebrew requires the
repository to be public and named `homebrew-<tap>`:

| Want users to type | Create repository |
| --- | --- |
| `brew tap ashishkp010/tap` | `ashishkp010/homebrew-tap` |

Push this directory to the root of that repository — `Casks/` and `scripts/` must sit at
the top level for Homebrew to find the cask.

## Why a tap and not the official homebrew-cask

Homebrew's [Acceptable Casks](https://docs.brew.sh/Acceptable-Casks) policy applies a
notability bar to submissions, and a stricter one when the submitter owns the project:
90 forks, 90 watchers and 225 stars. The Audify source repository is private, so an
official submission would be rejected today.

A tap has no gatekeeper, works with the same `brew install --cask` command users expect,
and stays entirely under Audify's control.

**The official route may be open after all — worth trying.** Homebrew's policy exempts
"a popular app that has their own website" from the repository notability bar, since the
*app* can be notable even when the repo is not. Audify Android has 100M+ downloads and 4.5
stars, which is a strong case. The tap costs nothing and works today, so ship it first —
then submit this same cask file to `homebrew-cask` unchanged, citing the install numbers.
Acceptance there would put Audify in front of every Mac user running `brew search`.
