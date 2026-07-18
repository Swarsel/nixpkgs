{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpptest";
  version = "2.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/cpptest/cpptest/cpptest-${finalAttrs.version}/cpptest-${finalAttrs.version}.tar.gz";
    sha256 = "0lpy3f2fjx1srh02myanlp6zfi497whlldcrnij39ghfhm0arcnm";
  };

  meta = {
    description = "Simple C++ unit testing framework";
    homepage = "http://cpptest.sourceforge.net/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ bosu ];
    platforms = lib.platforms.all;
  };
})
