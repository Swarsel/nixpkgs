{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  glew,
  glib,
  gtk3,
  libmad,
  libogg,
  libpulseaudio,
  libusb-compat-0_1,
  libvorbis,
  libxtst,
  makeDesktopItem,
  nasm,
  nix-update-script,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "itgmania";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "itgmania";
    repo = "itgmania";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dwalGEQFNhjuKwUBBskCHDYzmyjuf0r9TYM2ex8wzio=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    nasm
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    glew
    glib
    gtk3
    libmad
    libogg
    libpulseaudio
    libusb-compat-0_1
    libvorbis
    libxtst
    udev
  ];

  cmakeFlags = [
    "-DWITH_FULL_RELEASE=on"
    "-DWITH_NIGHTLY_RELEASE=off"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isx86) [ "-DWITH_MINIMAID=off" ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/scalable/apps/
    ln -s $out/itgmania/Data/logo.svg $out/share/icons/hicolor/scalable/apps/itgmania.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ArcadeGame"
      ];

      comment = "A cross-platform rhythm video game.";
      desktopName = "ITGmania";
      exec = "itgmania";
      genericName = "Rhythm and dance game";
      icon = "itgmania";
      name = "itgmania";
      terminal = false;
      tryExec = "itgmania";
      type = "Application";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of StepMania 5.1, improved for the post-ITG community";
    homepage = "https://www.itgmania.com/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ftsimas
      maxwell-lt
      ungeskriptet
    ];

    platforms = lib.platforms.linux;
    mainProgram = "itgmania";
  };
})
