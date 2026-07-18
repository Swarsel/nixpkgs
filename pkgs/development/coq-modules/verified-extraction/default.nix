{
  lib,
  ceres-bs,
  coq,
  dune,
  equations,
  metarocq-erasure-plugin,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "verified-extraction";
  buildInputs = [ dune ];

  propagatedBuildInputs = [
    coq.ocamlPackages.findlib
    coq.ocamlPackages.malfunction
    equations
    metarocq-erasure-plugin
    ceres-bs
  ];

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
    lib.switch
      [
        coq.coq-version
        metarocq-erasure-plugin.version
      ]
      [
        (case "9.1" "1.5.1-9.1" "1.0.0-9.1")
      ]
      null;

  mlPlugin = true;
  opam-name = "rocq-verified-extraction";
  owner = "MetaRocq";

  prePatch = ''
    patchShebangs plugin/plugin/clean_extraction.sh
  '';

  release = {
    "1.0.0-9.1".hash = "sha256-0eKpchQtnPI12rcsb9+qN1pdNX9KY8VryZP0oqHuYeU=";
  };

  releaseRev = v: "v${v}";
  repo = "rocq-verified-extraction";

  meta = with lib; {
    description = "Verified Extraction from Rocq to OCaml. Including a bootstrapped extraction plugin";
    homepage = "https://metarocq.github.io/";

    maintainers = with maintainers; [
      _4ever2
    ];
  };
}
