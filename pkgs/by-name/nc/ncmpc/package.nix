{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  fmt,
  gettext,
  glib,
  libmpdclient,
  meson,
  ncurses,
  ninja,
  pcre2,
  pkg-config,
  sphinx,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncmpc";
  version = "0.52";

  src = fetchFromGitHub {
    owner = "MusicPlayerDaemon";
    repo = "ncmpc";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-j/hZdKl1LQ/yEGDUv9k5PQJ6pngAl52mVCpfacWrRw0=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    sphinx
  ];

  buildInputs = [
    glib
    ncurses
    libmpdclient
    boost
    fmt
    pcre2
  ];

  mesonFlags = [
    (lib.mesonEnable "lirc" false)
  ];

  meta = {
    description = "Curses-based interface for MPD (music player daemon)";
    homepage = "https://www.musicpd.org/clients/ncmpc/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "ncmpc";
  };
})
