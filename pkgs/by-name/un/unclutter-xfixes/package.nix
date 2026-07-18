{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  docbook_xsl,
  libev,
  libx11,
  libxext,
  libxfixes,
  libxi,
  libxslt,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "unclutter-xfixes";
  version = "1.6-unstable-2024-11-25";

  src = fetchFromGitHub {
    owner = "Airblader";
    repo = "unclutter-xfixes";
    rev = "0eb7a8f4365c05d09db048bd1a45f8943c1d5da3";
    hash = "sha256-ipMifLFCh2vW8D9/KkxWL7W5T5dshRZ5wyQY0wgoaxQ=";
  };

  nativeBuildInputs = [
    pkg-config
    asciidoc
    libxslt
    docbook_xsl
  ];

  buildInputs = [
    libev
    libx11
    libxext
    libxi
    libxfixes
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];
  installFlags = [ "PREFIX=$(out)" ];

  prePatch = ''
    substituteInPlace Makefile --replace-fail 'PKG_CONFIG =' 'PKG_CONFIG ?='
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Rewrite of unclutter using the X11 Xfixes extension";
    homepage = "https://github.com/Airblader/unclutter-xfixes";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ryand56 ];
    platforms = lib.platforms.unix;
    mainProgram = "unclutter";
  };
}
