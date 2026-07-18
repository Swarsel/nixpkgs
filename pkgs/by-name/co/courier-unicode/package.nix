{
  lib,
  stdenv,
  fetchurl,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "courier-unicode";
  version = "2.6.0";

  src = fetchurl {
    url = "mirror://sourceforge/courier/courier-unicode/${finalAttrs.version}/courier-unicode-${finalAttrs.version}.tar.bz2";
    hash = "sha256-Cu0jScW2LeDTPM+MI1J6rkHa+VoDyAVMiN5Prvjaigg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    perl
  ];

  meta = {
    description = "Courier Unicode Library is used by most other Courier packages";
    homepage = "http://www.courier-mta.org/unicode/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
})
