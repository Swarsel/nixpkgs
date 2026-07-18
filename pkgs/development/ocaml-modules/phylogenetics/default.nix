{
  lib,
  fetchurl,
  alcotest,
  angstrom-unix,
  biotk,
  bppsuite,
  buildDunePackage,
  core,
  gsl,
  lacaml,
  menhir,
  menhirLib,
  printbox-text,
}:

buildDunePackage (finalAttrs: {
  pname = "phylogenetics";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/biocaml/phylogenetics/releases/download/v${finalAttrs.version}/phylogenetics-${finalAttrs.version}.tbz";
    hash = "sha256-3oZ9fMAXqOQ02rQ+8W8PZJWXOJLNe2qERrGOeTk3BKg=";
  };

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    angstrom-unix
    biotk
    core
    gsl
    lacaml
    menhirLib
    printbox-text
  ];

  doCheck = true;
  nativeCheckInputs = [ bppsuite ];
  checkInputs = [ alcotest ];

  checkPhase = ''
    runHook preCheck
    dune build @app/fulltest
    runHook postCheck
  '';

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Algorithms and datastructures for phylogenetics";
    homepage = "https://github.com/biocaml/phylogenetics";
    license = lib.licenses.cecill-b;
    maintainers = [ lib.maintainers.bcdarwin ];
    mainProgram = "phylosim";
  };
})
