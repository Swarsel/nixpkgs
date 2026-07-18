{
  mkKdeDerivation,
  qt5compat,
  qtmultimedia,
  qttools,
}:
mkKdeDerivation {
  pname = "konversation";
  extraBuildInputs = [ qt5compat ];

  extraNativeBuildInputs = [
    qtmultimedia
    qttools
  ];

  meta.mainProgram = "konversation";
}
