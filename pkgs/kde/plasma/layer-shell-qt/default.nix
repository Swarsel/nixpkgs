{
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "layer-shell-qt";
  extraBuildInputs = [ qtwayland ];
  extraNativeBuildInputs = [ pkg-config ];
}
