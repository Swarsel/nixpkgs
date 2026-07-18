{
  _7zz,
  libGLU,
  mkKdeDerivation,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kubrick";

  extraBuildInputs = [
    qtsvg
    libGLU
  ];

  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "kubrick";
}
