{
  mkKdeDerivation,
  packagekit-qt,
  pkg-config,
}:
mkKdeDerivation {
  pname = "frameworkintegration";
  extraBuildInputs = [ packagekit-qt ];
  extraNativeBuildInputs = [ pkg-config ];
}
