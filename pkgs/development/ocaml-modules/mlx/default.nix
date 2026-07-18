{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "mlx";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "ocaml-mlx";
    repo = "mlx";
    tag = finalAttrs.version;
    hash = "sha256-6cz/nbFGSxE1minncJujZi14TmM8ctDygJP4rmewYgo=";
  };

  buildInputs = [
    ppxlib
    menhir
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "OCaml syntax dialect which adds JSX syntax expressions";
    homepage = "https://github.com/ocaml-mlx/mlx";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ Denommus ];
  };
})
