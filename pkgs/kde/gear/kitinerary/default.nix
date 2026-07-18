{
  libphonenumber,
  mkKdeDerivation,
  poppler,
  protobuf,
  qtdeclarative,
  qtsvg,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kitinerary";

  extraBuildInputs = [
    qtsvg
    qtdeclarative
    poppler
    libphonenumber
    protobuf
  ];

  extraNativeBuildInputs = [ shared-mime-info ];
}
