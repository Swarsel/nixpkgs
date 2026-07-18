{
  lib,
  mkRocqDerivation,
  rocq-core,
  version ? null,
}:

with lib;
mkRocqDerivation {
  inherit version;
  pname = "rocqnavi";

  nativeBuildInputs =
    let
      ocamlpkgs = rocq-core.ocamlPackages;
    in
    [
      ocamlpkgs.yojson
      ocamlpkgs.dune-glob
    ];

  buildPhase = "make";

  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    with versions;
    switch rocq-core.rocq-version [
      (case (range "9.0" "9.2") "0.5.0")
    ] null;

  installFlags = [ "BINDIR=$(out)/bin" ];
  ## Does the package contain OCaml code?
  mlPlugin = true;
  owner = "affeldt-aist";
  preInstallPhase = "mkdir $(out)/bin";

  release = {
    "0.5.0".hash = "sha256-pmK4gD5ccerjr2UVgwGIVbjH/RiXdYQq79/XFetiHZg=";
  };

  releaseRev = v: "rocqnavi." + v;

  meta = {
    description = "Rocqnavi: an HTML documentation generator for Rocq prover";
    license = licenses.gpl2;
    maintainers = with maintainers; [ cohencyril ];
  };
}
