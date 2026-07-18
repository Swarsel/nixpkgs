{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libgcrypt,
  pkgsHostTarget,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libotr";
  version = "4.1.1";

  src = fetchurl {
    url = "https://otr.cypherpunks.ca/libotr-${finalAttrs.version}.tar.gz";
    sha256 = "1x8rliydhbibmzwdbyr7pd7n87m2jmxnqkpvaalnf4154hj1hfwb";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  patches = [ ./fix-regtest-client.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkgsHostTarget.libgcrypt.dev # for libgcrypt-config
  ];

  propagatedBuildInputs = [ libgcrypt ];

  meta = {
    description = "Library for Off-The-Record Messaging";
    homepage = "http://www.cypherpunks.ca/otr/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
  };
})
