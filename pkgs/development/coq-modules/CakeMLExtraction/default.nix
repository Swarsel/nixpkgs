{
  lib,
  ceres-bs,
  coq,
  equations,
  metarocq-erasure-plugin,
  mkCoqDerivation,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "CakeMLExtraction";

  buildInputs = [
    equations
    metarocq-erasure-plugin
    ceres-bs
  ];

  propagatedBuildInputs = [ coq.ocamlPackages.findlib ];

  defaultVersion =
    let
      case = coq: mr: out: {
        inherit out;

        cases = [
          coq
          mr
        ];
      };
    in
    with lib.versions;
    lib.switch
      [
        coq.coq-version
        metarocq-erasure-plugin.version
      ]
      [
        (case (range "9.0" "9.1") (range "1.4" "1.5.1") "0.1.0")
      ]
      null;

  mlPlugin = false;
  opam-name = "rocq-cakeml-extraction";
  owner = "peregrine-project";

  release = {
    "0.1.0".hash = "sha256-diDUTj0l4vliov9+Lg8lNRdkLE7JAfJn8OU7J/HgmDE=";
  };

  releaseRev = v: "v${v}";
  repo = "cakeml-backend";
  useDune = false;

  meta = with lib; {
    description = "CakeML backend for Peregrine";
    homepage = "https://peregrine-project.github.io/";
    maintainers = with maintainers; [ _4ever2 ];
  };
})
