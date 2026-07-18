{
  libxslt,
  mkKdeDerivation,
  qtmultimedia,
  qttools,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "mailcommon";

  extraBuildInputs = [
    qtmultimedia
    qttools
    qtwebengine
  ];

  extraNativeBuildInputs = [ libxslt ];
}
