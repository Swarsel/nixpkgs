{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  common-updater-scripts,
  curl,
  expat,
  ffmpeg,
  jre_headless,
  openssl,
  pkg-config,
  qt5,
  rubyPackages,
  writeShellApplication,
  zlib,
  withJava ? true,
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    inherit (finalAttrs) version;
    # Using two URLs as the first one will break as soon as a new version is released
    srcs.bin = fetchurl {
      hash = "sha256-zuVt4LqlUxq+0WvYYnQtMI13K0q02uFu6GW/dPBKFgg=";

      urls = [
        "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz"
        "http://www.makemkv.com/download/old/makemkv-bin-${version}.tar.gz"
      ];
    };
    srcs.oss = fetchurl {
      hash = "sha256-hZAGNkjULsKpWLdFc9cCLw9MM05OT+fdU7cMbnSLpFM=";

      urls = [
        "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz"
        "http://www.makemkv.com/download/old/makemkv-oss-${version}.tar.gz"
      ];
    };
  in
  {
    pname = "makemkv";
    version = "1.18.4";

    patches = [
      ./r13y.patch
      # This patch is sourced from NonGuix, licensed GPLv3:
      # https://gitlab.com/nonguix/nonguix/-/blob/2d1f3691546f007c7cd96ae87e4e970fed789182/nongnu/packages/patches/makemkv-app-id.patch
      ./app-id.patch
    ];

    nativeBuildInputs = [
      autoPatchelfHook
      pkg-config
      qt5.wrapQtAppsHook
    ];

    buildInputs = [
      expat
      ffmpeg
      openssl
      qt5.qtbase
      zlib
    ];

    installPhase = ''
      runHook preInstall

      install -Dm555 -t "$out"/bin                              out/{makemkv,mmccextr,mmgplsrv} \
                                                                ../makemkv-bin-"$version"/bin/amd64/makemkvcon
      install -D     -t "$out"/lib                              out/lib{driveio,makemkv,mmbd}.so.*
      install -D     -t "$out"/share/MakeMKV                    ../makemkv-bin-"$version"/src/share/*
      install -Dm444 -t "$out"/share/applications               ../makemkv-oss-"$version"/makemkvgui/share/makemkv.desktop
      install -Dm444 -t "$out"/share/icons/hicolor/16x16/apps   ../makemkv-oss-"$version"/makemkvgui/share/icons/16x16/*
      install -Dm444 -t "$out"/share/icons/hicolor/32x32/apps   ../makemkv-oss-"$version"/makemkvgui/share/icons/32x32/*
      install -Dm444 -t "$out"/share/icons/hicolor/64x64/apps   ../makemkv-oss-"$version"/makemkvgui/share/icons/64x64/*
      install -Dm444 -t "$out"/share/icons/hicolor/128x128/apps ../makemkv-oss-"$version"/makemkvgui/share/icons/128x128/*
      install -Dm444 -t "$out"/share/icons/hicolor/256x256/apps ../makemkv-oss-"$version"/makemkvgui/share/icons/256x256/*

      runHook postInstall
    '';

    enableParallelBuilding = true;

    qtWrapperArgs =
      let
        binPath = lib.makeBinPath [ jre_headless ];
      in
      lib.optionals withJava [ "--prefix PATH : ${binPath}" ];

    runtimeDependencies = [ (lib.getLib curl) ];
    sourceRoot = "makemkv-oss-${version}";
    srcs = lib.attrValues finalAttrs.passthru.srcs;

    passthru = {
      inherit srcs;

      updateScript = lib.getExe (writeShellApplication {
        name = "update-makemkv";
        runtimeEnv.oldVersion = version;

        runtimeInputs = [
          common-updater-scripts
          curl
          rubyPackages.nokogiri
        ];

        text = ''
          get_version() {
            # shellcheck disable=SC2016
            curl --fail --silent 'https://forum.makemkv.com/forum/viewtopic.php?f=3&t=224' \
              | nokogiri -e 'puts $_.css("head title").first.text.match(/\bMakeMKV (\d+\.\d+\.\d+) /)[1]'
          }
          newVersion=$(get_version)
          if [ "$oldVersion" == "$newVersion" ]; then
            echo "$0: New version same as old version, nothing to do." >&2
            exit
          fi
          update-source-version makemkv "$newVersion" --source-key=passthru.srcs.bin
          update-source-version makemkv "$newVersion" --source-key=passthru.srcs.oss --ignore-same-version
        '';
      });
    };

    meta = {
      description = "Convert blu-ray and dvd to mkv";

      longDescription = ''
        makemkv is a one-click QT application that transcodes an encrypted
        blu-ray or DVD disc into a more portable set of mkv files, preserving
        subtitles, chapter marks, all video and audio tracks.

        Program is time-limited -- it will stop functioning after 60 days. You
        can always download the latest version from makemkv.com that will reset the
        expiration date.
      '';

      homepage = "https://makemkv.com";

      license = [
        lib.licenses.unfree
        lib.licenses.lgpl21
      ];

      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ jchw ];
      platforms = [ "x86_64-linux" ];
    };
  }
)
