{
  lib,
  stdenv,
  fetchurl,
  pcre2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "leafnode";
  version = "1.12.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/leafnode/leafnode/${finalAttrs.version}/leafnode-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-tGfOcyH2F6IeglfY00u199eKusnn6HeqD7or3Oz3ed4=";
  };

  buildInputs = [ pcre2 ];

  configureFlags = [
    "--with-ipv6"
  ];

  meta = {
    description = "Implementation of a store & forward NNTP proxy, stable release";
    homepage = "https://leafnode.sourceforge.io/index.shtml";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
