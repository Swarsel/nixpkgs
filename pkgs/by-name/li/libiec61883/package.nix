{
  lib,
  stdenv,
  fetchurl,
  libraw1394,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libiec61883";
  version = "1.2.0";

  src = fetchurl {
    url = "mirror://debian/pool/main/libi/libiec61883/libiec61883_${finalAttrs.version}.orig.tar.gz";
    sha256 = "7c7879c6b9add3148baea697dfbfdcefffbc8ac74e8e6bcf46125ec1d21b373a";
    name = "libiec61883-${finalAttrs.version}.tar.gz";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ libraw1394 ];

  meta = {
    homepage = "https://www.linux1394.org";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
})
