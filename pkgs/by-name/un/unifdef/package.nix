{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unifdef";
  version = "2.12";

  src = fetchurl {
    url = "https://dotat.at/prog/unifdef/unifdef-${finalAttrs.version}.tar.xz";
    hash = "sha256-Q84PAuzc3HI7JHVXVWPdsZLpiMiG02gmC8CmOu46xAA=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/fanf2/unifdef/pull/19
    ./unifdef-fix-build-with-gcc15.patch
  ];

  makeFlags = [
    "prefix=$(out)"
    "DESTDIR="
  ];

  meta = {
    description = "Selectively remove C preprocessor conditionals";
    homepage = "https://dotat.at/prog/unifdef/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
