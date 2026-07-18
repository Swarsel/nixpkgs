{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  camlzip,
  numpy,
}:

buildDunePackage (finalAttrs: {
  pname = "npy";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "LaurentMazare";
    repo = "npy-ocaml";
    rev = finalAttrs.version;
    hash = "sha256:1fryglkm20h6kdqjl55b7065b34bdg3g3p6j0jv33zvd1m5888m1";
  };

  propagatedBuildInputs = [ camlzip ];
  doCheck = true;
  nativeCheckInputs = [ numpy ];
  duneVersion = "3";
  minimalOCamlVersion = "4.06";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "OCaml implementation of the Npy format spec";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
})
