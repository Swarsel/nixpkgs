{
  exiv2,
  libcamera,
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
  qtsensors,
}:
mkKdeDerivation {
  pname = "plasma-camera";

  extraBuildInputs = [
    qtmultimedia
    qtsensors

    exiv2
    libcamera
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
