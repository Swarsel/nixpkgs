{
  kitemmodels,
  mkKdeDerivation,
  qthttpserver,
  qtsvg,
  qtwebchannel,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "arianna";

  extraBuildInputs = [
    qthttpserver
    qtsvg
    qtwebchannel
    qtwebengine
    kitemmodels
  ];

  meta.mainProgram = "arianna";
}
