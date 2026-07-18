{
  lib,
  stdenv,
  fetchurl,
  gmp,
  libGL,
  libGLU,
  libglut,
  makeWrapper,
  mpfr,
  ocamlPackages,
  pkgsHostTarget,
}:

let
  inherit (pkgsHostTarget.targetPackages.stdenv) cc;
in

stdenv.mkDerivation rec {
  pname = "glsurf";
  version = "3.3.1";

  src = fetchurl {
    url = "https://raffalli.eu/~christophe/glsurf/glsurf-${version}.tar.gz";
    sha256 = "0w8xxfnw2snflz8wdr2ca9f5g91w5vbyp1hwlx1v7vg83d4bwqs7";
  };

  postPatch = ''
    for f in callbacks*/Makefile; do
      substituteInPlace "$f" --replace-warn "+camlp4" \
        "${ocamlPackages.camlp4}/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib/camlp4"
    done

    # Fatal error: exception Sys_error("Mutex.unlock: Operation not permitted")
    sed -i "/gl_started/d" src/draw.ml* src/main.ml

    # Compatibility with camlimages ≥ 5.0.5
    substituteInPlace src/Makefile --replace-warn camlimages.all_formats camlimages.core
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ (with ocamlPackages; [
    ocaml
    findlib
  ]);

  buildInputs = [
    libglut
    libGL
    libGLU
    mpfr
    gmp
  ]
  ++ (with ocamlPackages; [
    camlp4
    lablgl
    camlimages
    num
  ]);

  installPhase = ''
    mkdir -p $out/bin $out/share/doc/glsurf
    cp ./src/glsurf.opt $out/bin/glsurf
    cp ./doc/doc.pdf $out/share/doc/glsurf
    cp -r ./examples $out/share/doc/glsurf

    wrapProgram "$out/bin/glsurf" --set CC "${cc}/bin/${cc.targetPrefix}cc"
  '';

  meta = {
    description = "Program to draw implicit surfaces and curves";
    homepage = "https://raffalli.eu/~christophe/glsurf/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    mainProgram = "glsurf";
  };
}
