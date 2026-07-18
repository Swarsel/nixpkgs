{
  lib,
  stdenv,
  fetchurl,
  libx11,
  makeWrapper,
  tcl,
  tk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chessdb";
  version = "3.6.19-beta-1";

  src = fetchurl {
    url = "mirror://sourceforge/chessdb/ChessDB-${finalAttrs.version}.tar.gz";
    sha256 = "0brc3wln3bxp979iqj2w1zxpfd0pch8zzazhdmwf7acww4hrsz62";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    tcl
    tk
    libx11
  ];

  makeFlags = [
    "BINDIR=$(out)/bin"
    "SHAREDIR=$(out)/share/chessdb"
    "SOUNDSDIR=$(out)/share/chessdb/sounds"
    "TBDIR=$(out)/share/chessdb/tablebases"
    "MANDIR=$(out)/man"
  ];

  meta = {
    description = "Free chess database";
    homepage = "https://chessdb.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
