{
  lib,
  stdenv,
  fetchFromGitHub,
  jansson,
  pkg-config,
}:

let
  libsailing = fetchFromGitHub {
    owner = "sails-simulator";
    repo = "libsailing";
    rev = "9b2863ff0c539cd23d91b0254032a7af9c840574";
    sha256 = "06rcxkwgms9sxqr1swnnc4jnvgs0iahm4cksd475yd1bp5p1gq6j";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sailsd";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "sails-simulator";
    repo = "sailsd";
    rev = finalAttrs.version;
    sha256 = "1s4nlffp683binbdxwwzbsci61kbjylbcr1jf44sv1h1r5d5js05";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    jansson
    libsailing
  ];

  env.INSTALL_PATH = "$(out)";

  patchPhase = ''
    substituteInPlace Makefile \
      --replace gcc cc
  '';

  postUnpack = ''
    rmdir $sourceRoot/libsailing
    cp -r ${libsailing} $sourceRoot/libsailing
    chmod 755 -R $sourceRoot/libsailing
  '';

  meta = {
    description = "Simulator daemon for autonomous sailing boats";

    longDescription = ''
      Sails is a simulator designed to test the AI of autonomous sailing
      robots. It emulates the basic physics of sailing a small single sail
      boat'';

    homepage = "https://github.com/sails-simulator/sailsd";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ kragniz ];
    platforms = lib.platforms.all;
    mainProgram = "sailsd";
  };
})
