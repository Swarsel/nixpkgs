{
  lib,
  stdenv,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  # ffmpeg 7 not supported yet, results in MP4 playback being unavailable
  # https://repo.palemoon.org/MoonchildProductions/UXP/issues/2523
  ffmpeg_6,
  gtk2-x11,
  gtk3,
  libglvnd,
  libpulseaudio,
  libxt,
  makeDesktopItem,
  testers,
  wrapGAppsHook3,
  writeScript,
  withGTK3 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "palemoon-bin";
  version = "34.3.1";
  src = finalAttrs.passthru.sources."gtk${if withGTK3 then "3" else "2"}";
  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    gtk2-x11
    libxt
    (lib.getLib stdenv.cc.cc)
  ]
  ++ lib.optionals withGTK3 [
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/palemoon}
    cp -R * $out/lib/palemoon/

    ln -s $out/{lib/palemoon,bin}/palemoon

    for iconpath in chrome/icons/default/default{16,32,48} icons/mozicon128; do
      n=''${iconpath//[^0-9]/}
      size=$n"x"$n
      mkdir -p $out/share/icons/hicolor/$size/apps
      ln -s $out/lib/palemoon/browser/"$iconpath".png $out/share/icons/hicolor/$size/apps/palemoon.png
    done

    # Disable built-in updater
    # https://forum.palemoon.org/viewtopic.php?f=5&t=25073&p=197771#p197747
    # > Please do not take this as permission to change, remove, or alter any other preferences as that is forbidden
    # > without express permission according to the Pale Moon Redistribution License.
    # > We are allowing this one and **ONLY** one exception in order to properly facilitate [package manager] repacks.
    install -Dm644 ${./zz-disableUpdater.js} $out/lib/palemoon/browser/defaults/preferences/zz-disableUpdates.js

    runHook postInstall
  '';

  preFixup = ''
    # Make optional dependencies available
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          ffmpeg_6
          libglvnd
          libpulseaudio
        ]
      }"
    )
    wrapGApp $out/lib/palemoon/palemoon
  '';

  desktopItems = [
    (makeDesktopItem {
      actions = {
        "NewPrivateWindow" = {
          exec = "palemoon -private-window";
          name = "Open new private window";
        };

        "NewTab" = {
          exec = "palemoon -new-tab https://start.palemoon.org";
          name = "Open new tab";
        };

        "NewWindow" = {
          exec = "palemoon -new-window";
          name = "Open new window";
        };

        "ProfileManager" = {
          exec = "palemoon --ProfileManager";
          name = "Open the Profile Manager";
        };
      };

      categories = [
        "Network"
        "WebBrowser"
      ];

      comment = "Browse the World Wide Web";
      desktopName = "Pale Moon Web Browser";
      exec = "palemoon %u";

      extraConfig = {
        X-MultipleArgs = "false";
      };

      icon = "palemoon";

      keywords = [
        "Internet"
        "WWW"
        "Browser"
        "Web"
        "Explorer"
      ];

      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/rss+xml"
        "application/rdf+xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
        "x-scheme-handler/chrome"
        "video/webm"
        "application/x-xpinstall"
      ];

      name = "palemoon-bin";
      startupNotify = true;
      startupWMClass = "Pale moon";
      terminal = false;
      type = "Application";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  dontWrapGApps = true;
  preferLocalBuild = true;

  passthru = {
    sources =
      let
        urlRegionVariants =
          buildVariant:
          map
            (
              region:
              "https://rm-${region}.palemoon.org/release/palemoon-${finalAttrs.version}.linux-x86_64-${buildVariant}.tar.xz"
            )
            [
              "eu"
              "us"
            ];
      in
      {
        gtk2 = fetchzip {
          hash = "sha256-C48vM0LI6rPSS0wFVnPRlppT4I5EFnWzBFg/Rxw++Bw=";
          urls = urlRegionVariants "gtk2";
        };

        gtk3 = fetchzip {
          hash = "sha256-PFsdDuer6mbxFrcT0rSADcOxunoJIo3Y6O4NG4R8ygY=";
          urls = urlRegionVariants "gtk3";
        };
      };

    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = writeScript "update-palemoon-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts curl libxml2

      set -eu -o pipefail

      # Only release note announcement == finalized release
      version="$(
        curl -s 'http://www.palemoon.org/releasenotes.shtml' |
        xmllint --html --xpath 'html/body/table/tbody/tr/td/h3/text()' - 2>/dev/null | head -n1 |
        sed 's/v\(\S*\).*/\1/'
      )"

      for variant in gtk3 gtk2; do
        update-source-version palemoon-bin "$version" --ignore-same-version --source-key="sources.$variant"
      done
    '';
  };

  meta = {
    description = "Open Source, Goanna-based web browser focusing on efficiency and customization";

    longDescription = ''
      Pale Moon is an Open Source, Goanna-based web browser focusing on
      efficiency and customization.

      Pale Moon offers you a browsing experience in a browser completely built
      from its own, independently developed source that has been forked off from
      Firefox/Mozilla code a number of years ago, with carefully selected
      features and optimizations to improve the browser's stability and user
      experience, while offering full customization and a growing collection of
      extensions and themes to make the browser truly your own.
    '';

    homepage = "https://www.palemoon.org/";
    changelog = "https://repo.palemoon.org/MoonchildProductions/Pale-Moon/releases/tag/${finalAttrs.version}_Release";

    license = [
      lib.licenses.mpl20
      {
        fullName = "Pale Moon Redistribution License";
        url = "https://www.palemoon.org/redist.shtml";
        # TODO free, redistributable? Has strict limitations on what modifications may be done & shipped by packagers
      }
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "palemoon";
    hydraPlatforms = [ ];
  };
})
