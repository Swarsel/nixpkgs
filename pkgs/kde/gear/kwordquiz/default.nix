{
  mkKdeDerivation,
  qtmultimedia,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kwordquiz";

  extraBuildInputs = [
    qtsvg
    qtmultimedia
  ];

  meta.mainProgram = "kwordquiz";
}
