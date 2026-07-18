{
  intltool,
  mkKdeDerivation,
  qtdeclarative,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "kaccounts-providers";

  extraBuildInputs = [
    qtdeclarative
    qtwebengine
  ];

  extraNativeBuildInputs = [ intltool ];
}
