{
  _7zz,
  mkKdeDerivation,
  qtspeech,
  qtsvg,
}:
mkKdeDerivation {
  pname = "knights";

  extraBuildInputs = [
    qtsvg
    qtspeech
  ];

  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "knights";
}
