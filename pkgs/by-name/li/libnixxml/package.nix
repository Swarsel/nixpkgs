{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash,
  gd,
  getopt,
  glib,
  libxml2,
  libxslt,
  nix,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "libnixxml";
  version = "unstable-2020-06-25";

  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = "libnixxml";
    rev = "54c04a5fdbc8661b2445a7527f499e0a77753a1a";
    sha256 = "sha256-HKQnCkO1TDs1e0MDil0Roq4YRembqRHQvb7lK3GAftQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    getopt
    libxslt
  ];

  buildInputs = [
    bash
    libxml2
    gd.dev
    glib
    nix
  ];

  configureFlags = [
    "--with-gd"
    "--with-glib"
  ];

  env.CFLAGS = toString [
    "-Wall"
    "-std=c90"
  ];

  doCheck = true;

  nativeCheckInputs = [
    nix
  ];

  preAutoreconf = ''
    # Copied from bootstrap script
    ln -s README.md README
    mkdir -p config
  '';

  prePatch = ''
    # Remove broken test
    substituteInPlace tests/draw/Makefile.am \
      --replace "draw-wrong.sh" ""
    rm tests/draw/draw-wrong.sh

    # Fix bash path
    substituteInPlace scripts/nixexpr2xml.in \
      --replace "/bin/bash" "${bash}/bin/bash"
  '';

  meta = {
    description = "XML-based Nix-friendly data integration library";
    homepage = "https://github.com/svanderburg/libnixxml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomberek ];
    platforms = lib.platforms.unix;
  };
}
