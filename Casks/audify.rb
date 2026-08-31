cask "audify" do
  # The arm64 DMG has no suffix; the Intel one is "-Intel". Both names are fixed by the
  # existing appcast feeds, so this mapping must not change without updating the feeds.
  arch arm: "", intel: "-Intel"

  version "1.0.23"
  sha256 arm:   "ca2ecb4a4be0b36e380e0d94276d5304f900727b4f412551815ed7fd6163b2dc",
         intel: "326dc0b9ac47ae2299e2ce2db8cf291df9c1052137a66ec52079b8ef6b8281a5"

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
