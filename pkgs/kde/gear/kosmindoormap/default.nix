{
  bison,
  flex,
  mkKdeDerivation,
  recastnavigation,
}:
mkKdeDerivation {
  pname = "kosmindoormap";
  extraBuildInputs = [ recastnavigation ];

  extraNativeBuildInputs = [
    bison
    flex
  ];
}
