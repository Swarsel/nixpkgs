{
  bison,
  flex,
  libimobiledevice,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "solid";
  extraBuildInputs = [ libimobiledevice ];

  extraNativeBuildInputs = [
    qttools
    bison
    flex
  ];

  meta.mainProgram = "solid-hardware6";
}
