{
  lib,
  stdenv,
  fetchurl,
  frame,
  libx11,
  libxext,
  libxfixes,
  libxi,
  libxtst,
  pkg-config,
  python3,
  enableX11 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grail";
  version = "3.1.1";

  src = fetchurl {
    url = "https://launchpad.net/grail/trunk/${finalAttrs.version}/+download/grail-${finalAttrs.version}.tar.bz2";
    sha256 = "1wwx5ibjdz5pyd0f5cd1n91y67r68dymxpm2lgd829041xjizvay";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    python3
    frame
  ]
  ++ lib.optionals enableX11 [
    libx11
    libxtst
    libxext
    libxi
    libxfixes
  ];

  configureFlags = lib.optional enableX11 "--with-x11";

  meta = {
    description = "Gesture Recognition And Instantiation Library";
    homepage = "https://launchpad.net/canonical-multitouch/grail";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
