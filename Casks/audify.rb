cask "audify" do
  # The arm64 DMG has no suffix; the Intel one is "-Intel". Both names are fixed by the
  # existing appcast feeds, so this mapping must not change without updating the feeds.
  arch arm: "", intel: "-Intel"

  version "1.1.3"
  sha256 arm:   "efca4544fa139635b233321523c0f7832de9a3b7efa68591e790b8e454ed6b93",
         intel: "86049db6a87fdf39a69bd80879920c2878dbfc51ed111ef63d85e4978a884f7d"

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
