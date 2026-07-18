{
  discount,
  djvulibre,
  ebook_tools,
  fetchpatch,
  libspectre,
  libtiff,
  libzip,
  mkKdeDerivation,
  pkg-config,
  plasma-activities,
  poppler,
  qtspeech,
  qtsvg,
}:
mkKdeDerivation {
  pname = "okular";

  extraBuildInputs = [
    qtspeech
    qtsvg

    plasma-activities

    poppler
    libtiff
    libspectre
    libzip
    djvulibre
    ebook_tools
    discount
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "okular";
}
