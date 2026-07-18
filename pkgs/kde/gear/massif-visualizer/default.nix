{
  mkKdeDerivation,
  qt5compat,
  qtsvg,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "massif-visualizer";

  extraBuildInputs = [
    qt5compat
    qtsvg
  ];

  extraNativeBuildInputs = [ shared-mime-info ];
}
