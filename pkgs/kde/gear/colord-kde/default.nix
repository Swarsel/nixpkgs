{
  lcms2,
  libxrandr,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "colord-kde";

  extraBuildInputs = [
    lcms2
    libxrandr
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "colord-kde-icc-importer";
}
