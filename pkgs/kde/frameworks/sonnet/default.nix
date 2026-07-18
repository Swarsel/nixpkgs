{
  aspell,
  hunspell,
  mkKdeDerivation,
  pkg-config,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "sonnet";

  extraBuildInputs = [
    qtdeclarative
    aspell
    hunspell
  ];

  extraNativeBuildInputs = [
    qttools
    pkg-config
  ];

  meta.mainProgram = "parsetrigrams6";
}
