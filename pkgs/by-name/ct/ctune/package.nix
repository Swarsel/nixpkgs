{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  curl,
  ffmpeg,
  json_c,
  lame,
  libuuid,
  ncurses,
  openssl,
  pandoc,
  pipewire,
  pkg-config,
  vlc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ctune";
  version = "1.3.10";

  src = fetchFromGitHub {
    owner = "An7ar35";
    repo = "ctune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pC1xlcEX1f2kGewkq88iDAZwSlcRHmBpIw1aW74X6jw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    pandoc
  ];

  buildInputs = [
    openssl
    curl
    ffmpeg
    vlc
    SDL2
    lame
    json_c
    ncurses
    libuuid
    pipewire
  ];

  cmakeFlags = [
    # Avoid a wrong nested install path location
    # Set to "$out" instead of "$out/$out"
    "-DCMAKE_INSTALL_PREFIX=''"
  ];

  meta = {
    description = "Nice terminal nCurses (tui) internet radio player for Linux, browse and search from api.radio-browser.info";
    homepage = "https://github.com/An7ar35/ctune";
    changelog = "https://github.com/An7ar35/ctune/blob/master/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ theobori ];
    platforms = lib.platforms.linux;
    mainProgram = "ctune";
  };
})
