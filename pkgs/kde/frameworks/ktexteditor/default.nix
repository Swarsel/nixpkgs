{
  editorconfig-core-c,
  mkKdeDerivation,
  qtdeclarative,
  qtspeech,
}:
mkKdeDerivation {
  pname = "ktexteditor";

  extraBuildInputs = [
    qtdeclarative
    qtspeech
    editorconfig-core-c
  ];
}
