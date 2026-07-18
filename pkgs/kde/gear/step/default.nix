{
  eigen,
  gsl,
  libqalculate,
  mkKdeDerivation,
  pkg-config,
  qtsvg,
  qttools,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "step";

  extraBuildInputs = [
    eigen
    gsl
    libqalculate
  ];

  extraNativeBuildInputs = [
    qttools
    qtsvg
    pkg-config
    shared-mime-info
  ];

  meta.mainProgram = "step";
}
