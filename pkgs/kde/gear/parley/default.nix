{
  mkKdeDerivation,
  qtmultimedia,
  qtsvg,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "parley";

  extraBuildInputs = [
    qtsvg
    qtmultimedia
    qtwebengine
  ];

  meta.mainProgram = "parley";
}
