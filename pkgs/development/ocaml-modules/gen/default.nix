{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ocaml,
  ounit2,
  qcheck,
  seq,
}:

buildDunePackage (finalAttrs: {
  pname = "gen";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "gen";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZytPPGhmt/uANaSgkgsUBOwyQ9ka5H4J+5CnJpEdrNk=";
  };

  propagatedBuildInputs = [ seq ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    qcheck
    ounit2
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Simple, efficient iterators for OCaml";
    homepage = "https://github.com/c-cube/gen";
    license = lib.licenses.bsd3;
  };
})
