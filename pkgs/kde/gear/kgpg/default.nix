{
  gpgme,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kgpg";
  extraBuildInputs = [ gpgme ];
  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kgpg";
}
