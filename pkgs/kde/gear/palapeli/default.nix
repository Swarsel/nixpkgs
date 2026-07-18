{
  mkKdeDerivation,
  qtsvg,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "palapeli";
  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ shared-mime-info ];
  meta.mainProgram = "palapeli";
}
