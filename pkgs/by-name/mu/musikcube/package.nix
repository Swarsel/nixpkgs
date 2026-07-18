{
  lib,
  stdenv,
  fetchFromGitHub,
  # Linux Dependencies
  alsa-lib,
  asio,
  cmake,
  curl,
  ffmpeg-headless,
  game-music-emu,
  gnutls,
  lame,
  libev,
  libmicrohttpd,
  libopenmpt,
  mpg123,
  ncurses,
  pipewire,
  pkg-config,
  portaudio,
  pulseaudio,
  sndio,
  systemdLibs,
  taglib,
  pipewireSupport ? !stdenv.hostPlatform.isDarwin,
  sndioSupport ? true,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

let
  ffmpeg = ffmpeg-headless;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "musikcube";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "clangen";
    repo = "musikcube";
    tag = finalAttrs.version;
    hash = "sha512-qmoFMDmI4rvb5PrGgGoPlMwllG9H0B5uL4Xve/yQ8reQvQKIOWnt9e9oMm7gKO8eFAvFXiJLWUTpD3lTxZk1mQ==";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    asio
    curl
    ffmpeg
    gnutls
    lame
    libev
    game-music-emu
    libmicrohttpd
    libopenmpt
    mpg123
    ncurses
    portaudio
    taglib
  ]
  ++ lib.optionals systemdSupport [ systemdLibs ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    pulseaudio
  ]
  ++ lib.optionals sndioSupport [ sndio ]
  ++ lib.optionals pipewireSupport [ pipewire ];

  cmakeFlags = [ "-DDISABLE_STRIP=true" ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath $out/share/musikcube $out/share/musikcube/musikcube
    install_name_tool -add_rpath $out/share/musikcube $out/share/musikcube/musikcubed
  '';

  meta = {
    description = "Terminal-based music player, library, and streaming audio server";
    homepage = "https://musikcube.com/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      aanderse
      afh
    ];

    platforms = lib.platforms.all;
    mainProgram = "musikcube";
  };
})
