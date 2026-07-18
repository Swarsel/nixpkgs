{
  _7zz,
  mkKdeDerivation,
  qtsvg,
  svgcleaner,
}:
mkKdeDerivation {
  pname = "libkmahjongg";
  extraBuildInputs = [ qtsvg ];

  extraNativeBuildInputs = [
    _7zz
    svgcleaner
  ];
}
