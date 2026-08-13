cask "audify" do
  # The arm64 DMG has no suffix; the Intel one is "-Intel". Both names are fixed by the
  # existing appcast feeds, so this mapping must not change without updating the feeds.
  arch arm: "", intel: "-Intel"

  version "1.0.10"
  sha256 arm:   "11ea729e755229e09347fd5ea6085f4c9b5bcc3ddda5f98633f6998f467b5564",
         intel: "6db2d57b0f06018e5e90728e41ce89be75f47f7b5d58e59516877c899775eb33"

  url "https://download.audifyplayer.com/Audify-#{version}#{arch}.dmg",
      verified: "download.audifyplayer.com/"
  name "Audify"
  name "Audify Music Player"
  desc "Music and video player for a local library, with equalizer, radio and lyrics"
  homepage "https://audifyplayer.com/"

  # Same JSON feed the in-app updater reads, so `brew livecheck` and the app agree on
  # what the current version is. Both architectures ship together.
  livecheck do
    url "https://download.audifyplayer.com/appcast.json"
    strategy :json do |json|
      json["version"]
    end
  end

  app "Audify.app"

  # Paths come from AppDirs.dataDir and the java.util.prefs node "com/audify/desktop".
  zap trash: [
    "~/Library/Application Support/Audify",
    "~/Library/Preferences/com.audify.desktop.plist",
    "~/Library/Saved Application State/com.audify.desktop.savedState",
  ]
end
