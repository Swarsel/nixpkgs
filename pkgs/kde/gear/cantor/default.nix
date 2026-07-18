{
  libqalculate,
  libspectre,
  luajit,
  mkKdeDerivation,
  pkg-config,
  poppler,
  qtsvg,
  qttools,
  qtwebengine,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "cantor";

  extraBuildInputs = [
    qtsvg
    qttools
    qtwebengine

    libqalculate
    libspectre
    luajit
    poppler
    # FIXME: can't find R, Julia - if anyone needs this, feel free to investigate
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];
}
