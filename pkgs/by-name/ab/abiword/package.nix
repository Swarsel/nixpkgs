{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf-archive,
  autoreconfHook,
  boost,
  bzip2,
  enchant,
  fribidi,
  gitUpdater,
  goffice,
  gtk3,
  libgsf,
  libjpeg,
  libpng,
  librsvg,
  libxslt,
  perl,
  pkg-config,
  popt,
  wrapGAppsHook3,
  wv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abiword";
  version = "3.0.8";

  src = fetchFromGitLab {
    owner = "World";
    repo = "AbiWord";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-TjOHixfCXDQlUUbD1L5wcGe4Nl0+1UqZw4EF+1/eZ4w=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    patchShebangs ./tools/cdump/xp/cdump.pl ./po/ui-backport.pl
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
    wrapGAppsHook3
    perl
  ];

  buildInputs = [
    gtk3
    librsvg
    bzip2
    fribidi
    libpng
    popt
    libgsf
    enchant
    wv
    libjpeg
    boost
    libxslt
    goffice
  ];

  enableParallelBuilding = true;

  preAutoreconf = ''
    ./autogen-common.sh
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "release-";
  };

  meta = {
    description = "Word processing program, similar to Microsoft Word";
    homepage = "https://gitlab.gnome.org/World/AbiWord/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      pSub
      ylwghst
      sna
    ];

    platforms = lib.platforms.linux;
    mainProgram = "abiword";
  };
})
