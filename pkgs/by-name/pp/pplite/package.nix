{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  flint,
  gmp,
}:

stdenv.mkDerivation {
  pname = "pplite";
  version = "0.12";

  src = fetchurl {
    url = "https://github.com/ezaffanella/PPLite/raw/main/releases/pplite-0.12.tar.gz";
    hash = "sha256-9qulVEIZRPHV5GnVmp65nMrGrUwRGkR8i8ORbLdHb1E=";
  };

  patches = [
    # https://github.com/ezaffanella/PPLite/pull/1
    (fetchpatch {
      hash = "sha256-8FNyL8h/rBm2Hegib2l08vqEmFDU0PhMCV8Ui2G4xHQ=";
      name = "flint-3_2.patch";
      url = "https://github.com/ezaffanella/PPLite/commit/96fd1e50131f70bb78efdd60985525e970c9df06.patch";
    })
  ];

  buildInputs = [
    flint
    gmp
  ];

  meta = {
    description = "Convex polyhedra library for Abstract Interpretation";
    homepage = "https://github.com/ezaffanella/PPLite";
    license = lib.licenses.gpl3Only;
    mainProgram = "pplite_lcdd";
  };
}
