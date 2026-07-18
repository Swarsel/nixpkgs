{
  lib,
  fetchurl,
  libx11,
  makeDesktopItem,
  makeWrapper,
  tcl,
  tk,
  which,
  zlib,
}:

tcl.mkTclDerivation rec {
  pname = "scid-vs-pc";
  version = "4.27";

  src = fetchurl {
    url = "mirror://sourceforge/scidvspc/scid_vs_pc-${version}.tgz";
    hash = "sha256-aWN1w46dOW7VMACs8huvUsACtk3ggIS6BZ51BM9k+VM=";
  };

  postPatch = ''
    substituteInPlace configure Makefile.conf \
      --replace "~/.fonts" "$out/share/fonts/truetype/Scid" \
      --replace "which fc-cache" "false"
  '';

  nativeBuildInputs = [
    makeWrapper
    which
  ];

  buildInputs = [
    tk
    libx11
    zlib
  ];

  configureFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "SHAREDIR=${placeholder "out"}/share"
    "--with-tcl=${tcl}/lib"
    "--with-tclinclude=${tcl}/include"
    "--exec-prefix=${placeholder "out"}"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp $desktopItem/share/applications/* $out/share/applications/

    install -D icons/scid.png "$out"/share/icons/hicolor/128x128/apps/scid.png
  '';

  addTclConfigureFlags = false;

  desktopItem = makeDesktopItem {
    categories = [
      "Game"
      "BoardGame"
    ];

    comment = meta.description;
    desktopName = "Scid vs. PC";
    exec = "scid";
    genericName = "Chess Database";
    icon = "scid";
    name = "scid-vs-pc";
  };

  meta = {
    description = "Chess database with play and training functionality";
    homepage = "https://scidvspc.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.paraseba ];
    platforms = lib.platforms.linux;
    mainProgram = "scid";
  };
}
