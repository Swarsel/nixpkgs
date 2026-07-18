{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  mono,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taglib-sharp";
  version = "2.1.0.0";

  src = fetchFromGitHub {
    owner = "mono";
    repo = "taglib-sharp";
    rev = "taglib-sharp-${finalAttrs.version}";
    sha256 = "12pk4z6ag8w7kj6vzplrlasq5lwddxrww1w1ya5ivxrfki15h5cp";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    which
  ];

  buildInputs = [ mono ];
  configureFlags = [ "--disable-docs" ];
  dontStrip = true;

  meta = {
    description = "Library for reading and writing metadata in media files";
    homepage = "https://github.com/mono/taglib-sharp";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
  };
})
