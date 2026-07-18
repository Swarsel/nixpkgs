{
  lib,
  stdenv,
  fetchurl,
  libmnl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipset";
  version = "7.24";

  src = fetchurl {
    url = "https://ipset.netfilter.org/ipset-${finalAttrs.version}.tar.bz2";
    hash = "sha256-++NCTf8iLBy15cNNOLZFJLIhfOgCJsFP3LsTsp6jYRI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libmnl ];
  configureFlags = [ "--with-kmod=no" ];

  meta = {
    description = "Administration tool for IP sets";
    homepage = "https://ipset.netfilter.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "ipset";
  };
})
