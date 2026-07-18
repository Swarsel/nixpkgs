{
  mkKdeDerivation,
  perl,
  qtdeclarative,
  qttools,
}:
mkKdeDerivation {
  pname = "syntax-highlighting";
  extraBuildInputs = [ qtdeclarative ];

  extraNativeBuildInputs = [
    qttools
    perl
  ];

  meta.mainProgram = "ksyntaxhighlighter6";
}
