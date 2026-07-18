{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  gettext,
  glib,
  imagemagick,
  intltool,
  libpng,
  pkg-config,
  pstoedit,
}:

stdenv.mkDerivation rec {
  pname = "autotrace";
  version = "0.31.10";

  src = fetchFromGitHub {
    owner = "autotrace";
    repo = "autotrace";
    tag = version;
    hash = "sha256-PbEK5+7jcYIwYmgxBIOpNyj2KJNPfqKBKb+wYwoLKSo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    intltool
    pkg-config
  ];

  buildInputs = [
    glib
    imagemagick
    libpng
    pstoedit
  ];

  meta = {
    description = "Utility for converting bitmap into vector graphics";
    homepage = "https://github.com/autotrace/autotrace";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "autotrace";
  };
}
