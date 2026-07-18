{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  enchant,
  gettext,
  gitUpdater,
  gtk-doc,
  gtksourceview4,
  isocodes,
  itstool,
  libpeas,
  libxml2,
  mate-common,
  mate-desktop,
  perl,
  pkg-config,
  python3,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pluma";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "pluma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+3zY3A7JRc7utYMNiQBnsy0lZr1PuDSOtdP+iigNRDQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    gettext
    isocodes
    itstool
    gtk-doc
    mate-common # mate-common.m4 macros
    perl
    pkg-config
    python3.pkgs.wrapPython
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    enchant
    gtksourceview4
    libpeas
    libxml2
    mate-desktop
    python3
  ];

  postFixup = ''
    buildPythonPath "''${pythonPath[*]}"
    patchPythonScript $out/lib/pluma/plugins/snippets/Snippet.py
  '';

  enableParallelBuilding = true;

  pythonPath = with python3.pkgs; [
    pycairo
  ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "Powerful text editor for the MATE desktop";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
      fdl11Plus
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pluma";
    teams = [ lib.teams.mate ];
  };
})
