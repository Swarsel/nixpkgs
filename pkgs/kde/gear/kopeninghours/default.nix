{
  bison,
  boost,
  flex,
  mkKdeDerivation,
  python3,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kopeninghours";

  extraBuildInputs = [
    qtdeclarative
    (boost.override {
      enablePython = true;
      python = python3;
    })
    python3
  ];

  extraNativeBuildInputs = [
    bison
    flex
  ];
}
