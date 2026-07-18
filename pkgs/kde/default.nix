{
  lib,
  fetchurl,
  cmark,
  generateSplicesForMkScope,
  makeScopeWithSplicing',
  qt6Packages,
  taglib,
  wayland,
  wayland-protocols,
  zxing-cpp,
}:
let
  allPackages =
    self:
    let
      frameworks = import ./frameworks { inherit (self) callPackage; };
      gear = import ./gear { inherit (self) callPackage; };
      plasma = import ./plasma { inherit (self) callPackage; };

      sets = [
        "frameworks"
        "gear"
        "plasma"
      ];

      loadUrls = set: lib.importJSON (./generated/sources + "/${set}.json");
      allUrls = lib.attrsets.mergeAttrsList (map loadUrls sets);

      sources = lib.mapAttrs (
        _: v:
        (fetchurl {
          inherit (v) url hash;
        })
        // {
          inherit (v) version;
        }
      ) allUrls;
    in
    (
      qt6Packages
      // frameworks
      // gear
      // plasma
      // {
        # Aliases to simplify test-building entire package sets
        inherit
          sources
          frameworks
          gear
          plasma
          ;

        # THIRD PARTY
        inherit
          cmark
          taglib
          wayland
          wayland-protocols
          zxing-cpp
          ;

        alpaka = self.callPackage ./misc/alpaka { };
        applet-window-buttons6 = self.callPackage ./third-party/applet-window-buttons6 { };
        cxx-rust-cssparser = self.callPackage ./misc/cxx-rust-cssparser { };
        dynamic-workspaces = self.callPackage ./third-party/dynamic-workspaces { };
        glaxnimate = self.callPackage ./misc/glaxnimate { };
        karousel = self.callPackage ./third-party/karousel { };
        kdevelop-pg-qt = self.callPackage ./misc/kdevelop-pg-qt { };
        kdiagram = self.callPackage ./misc/kdiagram { };
        kdsoap-ws-discovery-client = self.callPackage ./misc/kdsoap-ws-discovery-client { };
        kio-extras-kf5 = self.callPackage ./misc/kio-extras-kf5 { };
        kio-fuse = self.callPackage ./misc/kio-fuse { };
        kirigami-addons = self.callPackage ./misc/kirigami-addons { };
        klevernotes = self.callPackage ./misc/klevernotes { };
        koi = self.callPackage ./third-party/koi { };
        # Alias to match metadata
        kquickimageeditor = self.kquickimageedit;
        krohnkite = self.callPackage ./third-party/krohnkite { };
        ktextaddons = self.callPackage ./misc/ktextaddons { };
        kup = self.callPackage ./misc/kup { };
        kzones = self.callPackage ./third-party/kzones { };
        marknote = self.callPackage ./misc/marknote { };
        mkKdeDerivation = self.callPackage (import ./lib/mk-kde-derivation.nix self) { };
        mpvqt = self.callPackage ./misc/mpvqt { };
        phonon = self.callPackage ./misc/phonon { };
        phonon-vlc = self.callPackage ./misc/phonon-vlc { };
        plasma-pass = self.callPackage ./misc/plasma-pass { };
        plasma-wayland-protocols = self.callPackage ./misc/plasma-wayland-protocols { };
        polkit-qt-1 = self.callPackage ./misc/polkit-qt-1 { };
        pulseaudio-qt = self.callPackage ./misc/pulseaudio-qt { };
        selenium-webdriver-at-spi = null; # Used for integration tests that we don't run, stub
        wallpaper-engine-plugin = self.callPackage ./third-party/wallpaper-engine-plugin { };
      }
    );
in
makeScopeWithSplicing' {
  f = allPackages;
  otherSplices = generateSplicesForMkScope "kdePackages";
}
