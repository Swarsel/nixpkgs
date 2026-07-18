{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxi,
  pkg-config,
  xorg-server,
  enableX11 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "frame";
  version = "2.5.0";

  src = fetchurl {
    url = "https://launchpad.net/frame/trunk/v${finalAttrs.version}/+download/frame-${finalAttrs.version}.tar.xz";
    sha256 = "bc2a20cd3ac1e61fe0461bd3ee8cb250dbcc1fa511fad0686d267744e9c78f3a";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    stdenv
  ]
  ++ lib.optionals enableX11 [
    xorg-server
    libx11
    libxext
    libxi
  ];

  configureFlags = lib.optional enableX11 "--with-x11";

  meta = {
    description = "Handles the buildup and synchronization of a set of simultaneous touches";
    homepage = "https://launchpad.net/frame";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "frame-test-x11";
  };
})
