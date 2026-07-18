{
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kguiaddons";
  extraBuildInputs = [ qtwayland ];
  extraNativeBuildInputs = [ pkg-config ];
  hasPythonBindings = true;
  meta.mainProgram = "kde-geo-uri-handler";
}
