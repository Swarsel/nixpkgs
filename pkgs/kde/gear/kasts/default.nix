{
  libvlc,
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
  qtsvg,
  taglib_1,
}:
mkKdeDerivation {
  pname = "kasts";

  extraBuildInputs = [
    qtsvg
    qtmultimedia
    taglib_1
    libvlc
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kasts";
}
