{
  boost,
  graphviz,
  mkKdeDerivation,
  pkg-config,
  qt5compat,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kgraphviewer";

  extraBuildInputs = [
    qt5compat
    qtsvg
    boost
    graphviz
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
