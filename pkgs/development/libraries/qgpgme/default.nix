{
  lib,
  stdenv,
  fetchurl,
  cmake,
  gpgmepp,
  qtbase,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qgpgme";
  version = "2.1.0";

  src = fetchurl {
    url = "mirror://gnupg/qgpgme/qgpgme-${finalAttrs.version}.tar.xz";
    hash = "sha256-WzL+s+7kp/lALSK3IGSAkI3EO7TfOCkXwHXFEhFvjwg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./includedir-absolute-path.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtbase
  ];

  propagatedBuildInputs = [
    gpgmepp
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_WITH_QT5" (lib.versions.major qtbase.version == "5"))
    (lib.cmakeBool "BUILD_WITH_QT6" (lib.versions.major qtbase.version == "6"))
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Qt API bindings/wrapper for GPGME";
    homepage = "https://dev.gnupg.org/source/gpgmeqt/";
    changelog = "https://dev.gnupg.org/source/gpgmeqt/browse/master/NEWS;gpgmeqt-${finalAttrs.version}?as=remarkup";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.unix;
  };
})
