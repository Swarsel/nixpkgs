{
  baloo,
  cfitsio,
  exiv2,
  kimageannotator,
  lcms2,
  libtiff,
  mkKdeDerivation,
  pkg-config,
  qtimageformats,
  qtmultimedia,
  qtsvg,
  qtwayland,
}:
mkKdeDerivation {
  pname = "gwenview";

  extraBuildInputs = [
    qtmultimedia
    qtsvg
    qtwayland

    # adds support for webp and other image formats
    qtimageformats

    cfitsio
    exiv2
    baloo
    kimageannotator
    lcms2
    libtiff
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
