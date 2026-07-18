{
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtremoteobjects";
  # cycle is detected in build when adding "dev" "bin" too
  outputs = [ "out" ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}
