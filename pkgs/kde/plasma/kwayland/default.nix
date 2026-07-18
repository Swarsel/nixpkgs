{
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kwayland";
  extraBuildInputs = [ qtwayland ];
  extraNativeBuildInputs = [ pkg-config ];
}
