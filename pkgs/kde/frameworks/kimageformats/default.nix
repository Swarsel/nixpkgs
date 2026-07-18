{
  libavif,
  libheif,
  libjxl,
  libraw,
  mkKdeDerivation,
  openexr,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kimageformats";

  extraBuildInputs = [
    libheif
    libjxl
    libavif
    libraw
    openexr
  ];

  extraCmakeFlags = [ "-DKIMAGEFORMATS_HEIF=1" ];
  extraNativeBuildInputs = [ pkg-config ];
}
