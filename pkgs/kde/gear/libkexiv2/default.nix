{
  exiv2,
  mkKdeDerivation,
  pkg-config,
  qt5compat,
}:
mkKdeDerivation {
  pname = "libkexiv2";

  extraBuildInputs = [
    qt5compat
    exiv2
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
