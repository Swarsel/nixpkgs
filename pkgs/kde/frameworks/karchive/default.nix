{
  mkKdeDerivation,
  pkg-config,
  qttools,
  xz,
}:
mkKdeDerivation {
  pname = "karchive";
  extraBuildInputs = [ xz ];

  extraNativeBuildInputs = [
    qttools
    pkg-config
  ];
}
