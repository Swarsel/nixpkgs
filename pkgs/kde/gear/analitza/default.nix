{
  eigen,
  mkKdeDerivation,
  qt5compat,
  qtdeclarative,
  qtsvg,
  qttools,
}:
mkKdeDerivation {
  pname = "analitza";

  extraBuildInputs = [
    qtdeclarative
    eigen
  ];

  extraNativeBuildInputs = [
    qt5compat
    qtsvg
    qttools
  ];
}
