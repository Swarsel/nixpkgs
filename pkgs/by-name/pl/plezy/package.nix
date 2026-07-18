{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  _7zz,
  copyDesktopItems,
  ffmpeg,
  flutter344,
  imagemagick,
  jdk,
  jsoncpp,
  keybinder3,
  libass,
  libevdev,
  libsecret,
  makeBinaryWrapper,
  makeDesktopItem,
  mpv-unwrapped,
  pkg-config,
  runCommand,
  stdenvNoCC,
  zlib,
  noto-fonts-cjk-sans ? null,
  use16kPagesizeWorkaround ? false,
}:

let
  pname = "plezy";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "edde746";
    repo = "plezy";
    tag = version;
    hash = "sha256-Fc2KWx4byfrulWzOGm0WW6EUXMvV8uwmvVjoSgzQmuA=";
  };

  simdutf = fetchurl {
    hash = "sha256-n+TW9RVySlXI3oj+5EY+CJChq+ImfNoTxLXSRdWAOeY=";
    url = "https://github.com/simdutf/simdutf/releases/download/v6.4.2/singleheader.zip";
  };

  zlib-root = runCommand "zlib-root" { } ''
    mkdir $out
    ln -s ${zlib.dev}/include $out/include
    ln -s ${zlib}/lib $out/lib
  '';

  meta = {
    description = "Modern cross-platform Plex & Jellyfin client built with Flutter";
    homepage = "https://github.com/edde746/plezy";
    license = lib.licenses.gpl3Only;

    sourceProvenance = lib.optionals stdenv.hostPlatform.isDarwin (
      with lib.sourceTypes; [ binaryNativeCode ]
    );

    maintainers = with lib.maintainers; [
      mio
      miniharinn
      BatteredBunny
    ];

    platforms = lib.platforms.linux ++ [
      "aarch64-darwin"
    ];

    mainProgram = "plezy";
  };

  linux = flutter344.buildFlutterApplication rec {
    inherit pname version src;
    inherit meta;

    patches = lib.optionals use16kPagesizeWorkaround [
      ./16k-font-workaround.patch
    ];

    postPatch = ''
      substituteInPlace linux/CMakeLists.txt \
        --replace-fail "URL https://github.com/simdutf/simdutf/releases/download/v6.4.2/singleheader.zip" \
                       "URL file://${simdutf}"
    ''
    + lib.optionalString use16kPagesizeWorkaround ''
      # Opt-in workaround for invisible text on aarch64-linux systems with 16K page size kernels
      # (e.g. Asahi Linux). Text was invisible; bundling the font as a Dart asset fixed it,
      # likely related to libflutter_linux_gtk.so being compiled with 4K page alignment only.
      install -Dm644 ${noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc assets/fonts/NotoSans.ttc
    '';

    nativeBuildInputs = [
      pkg-config
      copyDesktopItems
      imagemagick
    ];

    buildInputs = [
      libsecret
      jsoncpp
      mpv-unwrapped
      libass
      keybinder3
      ffmpeg
      zlib
      libevdev
      jdk
    ];

    env = {
      JAVA_HOME = "${jdk}/lib/openjdk";
      ZLIB_ROOT = zlib-root;
    };

    postInstall = ''
      install -Dm644 assets/plezy.png $out/share/icons/hicolor/128x128/apps/plezy.png
      for size in 16 24 32 48 64 256 512; do
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
        convert assets/plezy.png -resize ''${size}x''${size} $out/share/icons/hicolor/''${size}x''${size}/apps/plezy.png
      done
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [
          "AudioVideo"
          "Video"
          "Player"
        ];

        comment = meta.description;
        desktopName = "Plezy";
        exec = "plezy";
        icon = "plezy";
        name = "plezy";
      })
    ];

    gitHashes = lib.importJSON ./git-hashes.json;
    pubspecLock = lib.importJSON ./pubspec.lock.json;
    passthru.updateScript = ./update.sh;
  };

  darwin = stdenvNoCC.mkDerivation {
    inherit pname version;
    inherit meta;

    src = fetchurl {
      url = "https://github.com/edde746/plezy/releases/download/${version}/plezy-macos.dmg";
      hash = "sha256-jNwMukPYLTWBk1daanHtxYdJpZCB5I/hiKvFx4tL4sY=";
    };

    nativeBuildInputs = [
      _7zz
      makeBinaryWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications/Plezy.app
      cp -r . $out/Applications/Plezy.app
      makeBinaryWrapper $out/Applications/Plezy.app/Contents/MacOS/Plezy $out/bin/plezy

      runHook postInstall
    '';

    sourceRoot = "Plezy.app";
    passthru.updateScript = ./update.sh;
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
