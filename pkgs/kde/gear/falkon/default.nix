{
  extra-cmake-modules,
  mkKdeDerivation,
  python3Packages,
  qttools,
  qtwebchannel,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "falkon";

  extraBuildInputs = [
    extra-cmake-modules
    qtwebchannel
    qtwebengine
    python3Packages.pyside6
  ];

  extraNativeBuildInputs = [
    qttools
    qtwebchannel
    qtwebengine
  ];

  meta.mainProgram = "falkon";
}
