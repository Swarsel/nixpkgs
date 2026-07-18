{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  copyDesktopItems,
  kdePackages,
  libx11,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  openssl,
  util-linux,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poptracker";
  version = "0.35.3";

  src = fetchFromGitHub {
    owner = "black-sliver";
    repo = "PopTracker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HMuv6y8xPGI0+bI5/FCEnDwNbuP+Omcx2sn38d+6l7s=";
    fetchSubmodules = true;
  };

  patches = [ ./assets-path.diff ];

  postPatch = ''
    substituteInPlace src/poptracker.cpp --replace "@assets@" "$out/share/poptracker/"
  '';

  nativeBuildInputs = [
    util-linux
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    SDL2_ttf
    SDL2_image
    libx11
    openssl
    zlib
  ];

  buildFlags = [
    "native"
    "CONF=RELEASE"
    "VERSION=v${finalAttrs.version}"
  ];

  installPhase = ''
    runHook preInstall
    install -m555 -Dt $out/bin build/*/poptracker
    install -m444 -Dt $out/share/poptracker assets/*
    wrapProgram $out/bin/poptracker --prefix PATH : ${
      lib.makeBinPath [
        which
        kdePackages.kdialog
      ]
    }
    mkdir -p $out/share/icons/hicolor/{64x64,512x512}/apps
    ln -s $out/share/poptracker/icon.png  $out/share/icons/hicolor/64x64/apps/poptracker.png
    ln -s $out/share/poptracker/icon512.png  $out/share/icons/hicolor/512x512/apps/poptracker.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Utility"
      ];

      comment = "Universal, scriptable randomizer tracking solution";
      desktopName = "PopTracker";
      exec = "poptracker";
      icon = "poptracker";
      name = "poptracker";
    })
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scriptable tracker for randomized games";

    longDescription = ''
      Universal, scriptable randomizer tracking solution that is open source. Supports auto-tracking.

      PopTracker packs should be placed in `~/PopTracker/packs` or `./packs`.
    '';

    homepage = "https://github.com/black-sliver/PopTracker";
    changelog = "https://github.com/black-sliver/PopTracker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      freyacodes
      pyrox0
    ];

    platforms = lib.platforms.unix;
    mainProgram = "poptracker";
  };
})
