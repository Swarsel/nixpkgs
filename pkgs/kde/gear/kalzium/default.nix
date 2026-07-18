{
  eigen,
  mkKdeDerivation,
  ocaml,
  openbabel,
  pkg-config,
  qtscxml,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kalzium";

  extraBuildInputs = [
    eigen
    openbabel
    qtsvg
    qtscxml
  ];

  # FIXME: look into how to make it find libfacile
  extraNativeBuildInputs = [
    pkg-config
    ocaml
  ];

  meta.mainProgram = "kalzium";
}
