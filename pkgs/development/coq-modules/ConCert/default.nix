{
  lib,
  QuickChick,
  TypedExtraction,
  bignums,
  coq,
  metarocq-erasure,
  mkCoqDerivation,
  stdpp,
  which,
  version ? null,
}:

with lib;
mkCoqDerivation {
  inherit version;
  pname = "ConCert";
  postPatch = "patchShebangs ./extraction/process-extraction-examples.sh";

  propagatedBuildInputs = [
    coq.ocamlPackages.findlib
    metarocq-erasure
    bignums
    QuickChick
    stdpp
    TypedExtraction
  ];

  buildPhase = ''
    make core
  '';

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in

    lib.switch coq.coq-version [
      (case "9.1" "1.0.1")
    ] null;

  domain = "github.com";
  owner = "AU-COBRA";
  release."1.0.0".hash = "sha256-R+kWOZtR7T2LVQnHmLGDmGpLO0S76fPRWJpsO9nWqLE=";
  release."1.0.1".hash = "sha256-HqbgUnGcZHkeG6qLf4qp/JT5oTPmdfOn1IJqnrloM2U=";
  releaseRev = v: "v${v}";
  repo = "ConCert";

  meta = {
    description = "A framework for smart contract verification in Rocq";
    license = licenses.mit;
    maintainers = with maintainers; [ _4ever2 ];
  };
}
