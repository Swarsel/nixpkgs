{
  libmaxminddb,
  mkKdeDerivation,
  qtwebengine,
  taglib,
}:
mkKdeDerivation {
  pname = "ktorrent";

  extraBuildInputs = [
    qtwebengine
    taglib
    libmaxminddb
  ];
}
