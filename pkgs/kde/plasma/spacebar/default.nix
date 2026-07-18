{
  c-ares,
  curl,
  libphonenumber,
  mkKdeDerivation,
  pkg-config,
  protobuf,
}:
mkKdeDerivation {
  pname = "spacebar";

  extraBuildInputs = [
    c-ares
    curl
    libphonenumber
    protobuf
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
