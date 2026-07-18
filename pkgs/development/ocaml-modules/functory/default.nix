{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
}:

let
  param =
    if lib.versionAtLeast ocaml.version "4.02" then
      {
        version = "0.6";
        sha256 = "18wpyxblz9jh5bfp0hpffnd0q8cq1b0dqp0f36vhqydfknlnpx8y";
      }
    else
      {
        version = "0.5";
        sha256 = "1j17rhifdjv1z262dma148ywg34x0zjn8vczdrnkwajsm4qg1hw3";
      };
in

stdenv.mkDerivation {
  inherit (param) version;
  pname = "ocaml${ocaml.version}-functory";

  src = fetchurl {
    inherit (param) sha256;
    url = "https://www.lri.fr/~filliatr/functory/download/functory-${param.version}.tar.gz";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  createFindlibDestdir = true;
  installTargets = [ "ocamlfind-install" ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Distributed computing library for Objective Caml which facilitates distributed execution of parallelizable computations in a seamless fashion";
    homepage = "https://www.lri.fr/~filliatr/functory/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
