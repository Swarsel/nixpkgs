{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  directfb,
  gpm,
  libavif, # graphic formats
  libev, # Misc.
  libjpeg,
  libpng,
  librsvg,
  libtiff,
  libx11,
  libxau, # GUI support
  libxt,
  openssl,
  pkg-config,
  xz, # Transfer encodings
  zlib,
  enableDirectFB ? false,
  enableFB ? (!stdenv.hostPlatform.isDarwin),
  enableX11 ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "links2";
  version = "2.30";

  src = fetchurl {
    url = "https://links.twibright.com/download/links-${finalAttrs.version}.tar.bz2";
    hash = "sha256-xGMca1oRUnzcPLeHL8I7fyslwrAh1Za+QQ2ttAMV8WY=";
  };

  nativeBuildInputs = [
    pkg-config
    bzip2
  ];

  buildInputs = [
    libev
    librsvg
    libpng
    libjpeg
    libtiff
    libavif
    openssl
    xz
    bzip2
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ gpm ]
  ++ lib.optionals enableX11 [
    libx11
    libxau
    libxt
  ]
  ++ lib.optionals enableDirectFB [ directfb ];

  configureFlags = [
    "--with-ssl"
  ]
  ++ lib.optional (enableX11 || enableFB || enableDirectFB) "--enable-graphics"
  ++ lib.optional enableX11 "--with-x"
  ++ lib.optional enableFB "--with-fb"
  ++ lib.optional enableDirectFB "--with-directfb";

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-int";
  };

  meta = {
    description = "Small browser with some graphics support";
    homepage = "http://links.twibright.com/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "links";
  };
})
