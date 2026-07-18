{
  lib,
  graphviz,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kcachegrind";
  extraNativeBuildInputs = [ qttools ];

  qtWrapperArgs = [
    "--suffix PATH : ${lib.makeBinPath [ graphviz ]}"
  ];
}
