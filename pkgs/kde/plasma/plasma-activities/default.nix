{
  boost,
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "plasma-activities";

  extraBuildInputs = [
    qtdeclarative
    boost
  ];

  meta.mainProgram = "plasma-activities-cli6";
}
