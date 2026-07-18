{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
  menhirLib,
  ppx_expect,
  sexplib0,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "kdl";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "eilvelia";
    repo = "ocaml-kdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0MiJe0XbWAlS2NvGxLplsgVfCNaA/7iCMx4+F+6FAtM=";
  };

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    menhirLib
    sexplib0
  ];

  doCheck = true;

  checkInputs = [
    ppx_expect
    zarith
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "OCaml implementation of the KDL Document Language v2";
    homepage = "https://github.com/eilvelia/ocaml-kdl";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ toastal ];
  };
})
