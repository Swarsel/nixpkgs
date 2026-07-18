{
  callaudiod,
  libphonenumber,
  mkKdeDerivation,
  pkg-config,
  protobuf,
  qtbase,
}:
mkKdeDerivation {
  pname = "plasma-dialer";

  extraBuildInputs = [
    callaudiod
    libphonenumber
    protobuf
  ];

  extraCmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${qtbase}/libexec/qtwaylandscanner"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
