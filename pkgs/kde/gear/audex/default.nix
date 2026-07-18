{
  libcdio,
  libcdio-paranoia,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "audex";

  extraBuildInputs = [
    libcdio
    libcdio-paranoia
  ];
}
