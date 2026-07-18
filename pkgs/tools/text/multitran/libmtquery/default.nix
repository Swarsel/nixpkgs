{
  lib,
  stdenv,
  fetchurl,
  libbtree,
  libfacet,
  libmtsupport,
  multitrandata,
}:

stdenv.mkDerivation rec {
  pname = "libmtquery";
  version = "0.0.1alpha3";

  src = fetchurl {
    url = "mirror://sourceforge/multitran/libmtquery-${version}.tar.bz2";
    sha256 = "e24c7c15772445f1b14871928d84dd03cf93bd88f9d2b2ed1bf0257c2cf2b15e";
  };

  buildInputs = [
    libmtsupport
    libfacet
    libbtree
    multitrandata
  ];

  env.NIX_LDFLAGS = "-lbtree";

  patchPhase = ''
    sed -i -e 's@\$(DESTDIR)/usr@'$out'@' \
      -e 's@/usr/include/mt/support@${libmtsupport}/include/mt/support@' \
      -e 's@/usr/include/btree@${libbtree}/include/btree@' \
      -e 's@/usr/include/facet@${libfacet}/include/facet@' \
      src/Makefile testsuite/Makefile;
    sed -i -e 's@/usr/share/multitran@${multitrandata}/share/multitran@' src/config.cc
  '';

  meta = {
    description = "Multitran lib: main engine to query translations";
    homepage = "https://multitran.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
