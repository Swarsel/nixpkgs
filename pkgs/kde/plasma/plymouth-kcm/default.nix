{
  mkKdeDerivation,
  pkg-config,
  plymouth,
}:
mkKdeDerivation {
  pname = "plymouth-kcm";
  extraBuildInputs = [ plymouth ];
  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kplymouththemeinstaller";
}
