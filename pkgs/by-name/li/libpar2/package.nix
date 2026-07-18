{
  lib,
  stdenv,
  fetchurl,
  libsigcxx,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpar2";
  version = "0.4";

  src = fetchurl {
    url = "https://launchpad.net/libpar2/trunk/${finalAttrs.version}/+download/libpar2-${finalAttrs.version}.tar.gz";
    sha256 = "1m4ncws1h03zq7zyqbaymvjzzbh1d3lc4wb1aksrdf0ync76yv9i";
  };

  patches = [ ./libpar2-0.4-external-verification.patch ];
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsigcxx ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    CXXFLAGS = "-std=c++11";
  };

  meta = {
    description = "Library for using Parchives (parity archive volume sets)";
    homepage = "https://parchive.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
