{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  cairo,
  libkate,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtiger";
  version = "0.3.4";

  src = fetchurl {
    url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/libtiger/libtiger-${finalAttrs.version}.tar.gz";
    sha256 = "0rj1bmr9kngrgbxrjbn4f4f9pww0wmf6viflinq7ava7zdav4hkk";
  };

  patches = [
    ./pkg-config.patch
  ];

  postPatch = ''
    substituteInPlace configure.ac --replace "-Werror" "-Wno-error"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libkate
    pango
    cairo
  ];

  meta = {
    description = "Rendering library for Kate streams using Pango and Cairo";
    homepage = "https://code.google.com/archive/p/libtiger/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
