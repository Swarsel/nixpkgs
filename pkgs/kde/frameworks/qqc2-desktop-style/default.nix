{
  kirigami,
  mkKdeDerivation,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "qqc2-desktop-style";
  excludeDependencies = [ "kirigami" ];

  extraBuildInputs = [
    qtdeclarative
    kirigami.unwrapped
  ];

  extraNativeBuildInputs = [ qttools ];
}
