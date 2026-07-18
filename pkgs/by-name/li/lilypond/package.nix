{
  lib,
  stdenv,
  autoreconfHook,
  bison,
  boehmgc,
  coreutils,
  dblatex,
  extractpdfmark,
  fetchzip,
  flex,
  fontconfig,
  fontforge,
  freefont_ttf,
  freetype,
  gettext,
  ghostscript,
  glib,
  gmp,
  guile,
  help2man,
  imagemagick,
  makeFontsConf,
  makeWrapper,
  pango,
  perl,
  pkg-config,
  python3,
  rsync,
  t1utils,
  texi2html,
  texinfo,
  texliveSmall,
  writeScript,
  tex ? texliveSmall.withPackages (
    ps: with ps; [
      epsf
      fontinst
      fontware
      lh
      metafont
    ]
  ),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lilypond";
  version = "2.26.0";

  src = fetchzip {
    url = "https://lilypond.org/download/sources/v${lib.versions.majorMinor finalAttrs.version}/lilypond-${finalAttrs.version}.tar.gz";
    hash = "sha256-HUkPhaWNZ4UKbmlEyLXepHCFcgrdoRSDtjZMriO68RM=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
    dblatex
    extractpdfmark
    flex # for flex binary
    fontconfig
    fontforge
    gettext
    ghostscript
    guile
    help2man
    imagemagick
    makeWrapper
    perl
    pkg-config
    python3
    rsync
    t1utils
    tex
    texi2html
    texinfo
  ];

  buildInputs = [
    boehmgc
    flex # FlexLexer.h
    freetype
    glib
    gmp
    pango
  ];

  # documentation makefile uses "out" for different purposes, hence we explicitly set it to an empty string
  makeFlags = [ "out=" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    FONTCONFIG_FILE = (
      makeFontsConf {
        fontDirectories = [ freefont_ttf ];
      }
    );
  };

  preConfigure = ''
    substituteInPlace scripts/build/mf2pt1.pl \
      --replace-fail "mem=mf2pt1" "mem=$PWD/mf/mf2pt1"
  '';

  postInstall = ''
    for f in "$out/bin/"*; do
        # Override default argv[0] setting so LilyPond can find
        # its Scheme libraries.
        wrapProgram "$f" \
          --set GUILE_AUTO_COMPILE 0 \
          --prefix PATH : "${
            lib.makeBinPath [
              ghostscript
              coreutils
              (placeholder "out")
            ]
          }" \
          --argv0 "$f"
    done
  '';

  autoreconfPhase = "NOCONFIGURE=1 sh autogen.sh";

  depsBuildBuild = [
    pkg-config
  ];

  enableParallelBuilding = true;

  passthru.updateScript = writeScript "update-lilypond" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts curl
    version="$(curl -s 'https://gitlab.com/lilypond/lilypond/-/raw/master/VERSION' | grep 'VERSION_STABLE=' | cut -d= -f2)"
    update-source-version lilypond "$version"
  '';

  meta = {
    description = "Music typesetting system";
    homepage = "https://lilypond.org/";

    license = with lib.licenses; [
      gpl3Plus # most code
      gpl3Only # ly/articulate.ly
      fdl13Plus # docs
      ofl # mf/
    ];

    maintainers = with lib.maintainers; [
      eclairevoyant
      yurrriq
    ];

    platforms = lib.platforms.all;
  };
})
