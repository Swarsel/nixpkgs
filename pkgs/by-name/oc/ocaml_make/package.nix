{
  lib,
  stdenv,
  fetchurl,
}:

let

  version = "6.37.0";
  sha256 = "99ff58080ed154cc4bd70f915fe4760dffb026a1c0447caa0b3bdb982b24b0a8";

in
stdenv.mkDerivation {
  inherit version;
  pname = "ocaml-make";

  src = fetchurl {
    inherit sha256;
    url = "https://bitbucket.org/mmottl/ocaml-makefile/downloads/ocaml-makefile-${version}.tar.gz";
  };

  installPhase = ''
    mkdir -p "$out/include/"
    cp OCamlMakefile "$out/include/"
  '';

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Generic OCaml Makefile for GNU Make";
    homepage = "http://www.ocaml.info/home/ocaml_sources.html";

    license = with lib.licenses; [
      lgpl21Only
      ocamlLgplLinkingException
      gpl3Only
    ];

    platforms = lib.platforms.unix;
  };
}
