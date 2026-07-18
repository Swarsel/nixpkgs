{
  gperf,
  mkKdeDerivation,
  qttools,
}:
mkKdeDerivation {
  pname = "kcodecs";

  extraNativeBuildInputs = [
    qttools
    gperf
  ];
}
