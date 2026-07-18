{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  dconf,
  gettext,
  gitUpdater,
  itstool,
  libxml2,
  mate-common,
  mate-desktop,
  nixosTests,
  pcre2,
  pkg-config,
  vte,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-terminal";
  version = "1.28.3";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "mate-terminal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fgmYqcv+36QjOFVB7gdBrUi6eZhWFLsJa3Pm27Idx8E=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    gettext
    itstool
    mate-common # mate-common.m4 macros
    pkg-config
    libxml2 # xmllint
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    dconf
    mate-desktop
    pcre2
    vte
  ];

  enableParallelBuilding = true;
  passthru.tests.test = nixosTests.terminal-emulators.mate-terminal;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "MATE desktop terminal emulator";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
