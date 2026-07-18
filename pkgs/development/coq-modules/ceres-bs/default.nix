{
  lib,
  coq,
  metarocq-utils,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {

  inherit version;
  pname = "ceres-bs";

  propagatedBuildInputs = [
    coq.ocamlPackages.findlib
    stdlib
    metarocq-utils
  ];

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with lib.versions;
    lib.switch coq.version [
      (case (range "9.0" "9.1") "1.0.0")
    ] null;

  opam-name = "rocq-ceres-bytestring";
  owner = "peregrine-project";
  release."1.0.0".hash = "sha256-aB/YWw4E1myIYDRlNs/dEXoI9HDKl1/lsPGMYzjyJsU=";
  releaseRev = v: "v${v}";
  repo = "rocq-ceres-bytestring";
  useDune = true;

  meta = {
    description = "Library for serialization via S-expressions using bytestrings. Alternative to coq-ceres which uses String from standard library.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _4ever2 ];
  };
}
