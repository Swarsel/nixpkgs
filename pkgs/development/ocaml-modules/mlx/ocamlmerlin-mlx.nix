{
  lib,
  buildDunePackage,
  cppo,
  csexp,
  menhir,
  merlin-lib,
  mlx,
  odoc,
  ppxlib,
}:
buildDunePackage {
  inherit (mlx) version src;
  pname = "ocamlmerlin-mlx";

  nativeBuildInputs = [
    cppo
  ];

  buildInputs = [
    ppxlib
    merlin-lib
    csexp
    menhir
    odoc
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "Merlin support for MLX OCaml dialect";
    homepage = "https://github.com/ocaml-mlx/mlx";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.Denommus ];
    mainProgram = "ocamlmerlin-mlx";
  };
}
