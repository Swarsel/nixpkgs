{
  lib,
  stdenv,
  autoreconfHook,
  callPackage,
  fetchFromRepoOrCz,
  giflib,
  imagemagick,
  libexif,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  libx11,
  libxext,
  libxft,
  libxinerama,
  libxmu,
  libxpm,
  libxrandr,
  libxres,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "windowmaker";
  version = "0.96.0";

  src = fetchFromRepoOrCz {
    repo = "wmaker-crm";
    rev = "wmaker-${finalAttrs.version}";
    hash = "sha256-6DS5KztCNWPQL6/qJ5vlkOup2ourxSNf6LLTFYpPWi8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    giflib
    imagemagick
    libx11
    libxext
    libxft
    libxinerama
    libxmu
    libxpm
    libxrandr
    libxres
    libexif
    libjpeg
    libpng
    libtiff
    libwebp
    pango
  ];

  configureFlags = [
    "--enable-modelock"
    "--enable-randr"
    "--enable-webp"
    "--with-x"
  ];

  passthru = {
    dockapps = callPackage ./dockapps { };
  };

  meta = {
    description = "NeXTSTEP-like window manager";

    longDescription = ''
      Window Maker is an X11 window manager originally designed to provide
      integration support for the GNUstep Desktop Environment. In every way
      possible, it reproduces the elegant look and feel of the NEXTSTEP user
      interface. It is fast, feature rich, easy to configure, and easy to
      use. It is also free software, with contributions being made by
      programmers from around the world.
    '';

    homepage = "http://windowmaker.org/";
    changelog = "https://www.windowmaker.org/news/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "wmaker";
  };
})
