{
  attr,
  ebook_tools,
  exiv2,
  ffmpeg,
  kconfig,
  kdegraphics-mobipocket,
  libappimage,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kfilemetadata";
  # Fix installing cmake files into wrong directory
  # FIXME(later): upstream
  patches = [ ./cmake-install-paths.patch ];

  extraBuildInputs = [
    attr
    ebook_tools
    exiv2
    ffmpeg
    kconfig
    kdegraphics-mobipocket
    libappimage
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
