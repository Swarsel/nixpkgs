{
  bison,
  flex,
  mkKdeDerivation,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "kholidays";
  extraBuildInputs = [ qtdeclarative ];

  extraNativeBuildInputs = [
    qttools

    bison
    flex
  ];
}
