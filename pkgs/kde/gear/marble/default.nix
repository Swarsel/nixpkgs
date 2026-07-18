{
  gpsd,
  krunner,
  libplasma,
  mkKdeDerivation,
  perl,
  phonon,
  pkg-config,
  protobuf,
  qtpositioning,
  qtsvg,
  qttools,
  qtwebengine,
  shapelib,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "marble";
  # breaks with split outputs
  # FIXME: track this down
  outputs = [ "out" ];

  extraBuildInputs = [
    qtpositioning
    qtsvg
    qttools
    qtwebengine

    krunner
    libplasma
    phonon

    gpsd
    # FIXME: libwlocate
    protobuf
    shapelib
  ];

  extraNativeBuildInputs = [
    perl
    pkg-config
    shared-mime-info
  ];
}
