{
  buildDunePackage,
  cmdliner,
  ocamlformat-mlx-lib,
  odoc,
  re,
}:
buildDunePackage {
  inherit (ocamlformat-mlx-lib) version src meta;
  pname = "ocamlformat-mlx";

  buildInputs = [
    cmdliner
    re
    odoc
    ocamlformat-mlx-lib
  ];

  minimalOcamlVersion = "4.08";
}
