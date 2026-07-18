{
  _7zz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "killbots";
  extraNativeBuildInputs = [ _7zz ];
  meta.mainProgram = "killbots";
}
