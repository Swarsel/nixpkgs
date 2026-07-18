{
  libxt,
  mkKdeDerivation,
  qtmultimedia,
}:
mkKdeDerivation {
  pname = "kmousetool";

  extraBuildInputs = [
    qtmultimedia
    libxt
  ];

  meta.mainProgram = "kmousetool";
}
