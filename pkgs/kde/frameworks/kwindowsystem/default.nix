{
  mkKdeDerivation,
  pkg-config,
  qtdeclarative,
  qttools,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kwindowsystem";

  extraBuildInputs = [
    qtdeclarative
    qtwayland
  ];

  extraNativeBuildInputs = [
    qttools
    pkg-config
  ];
}
