{
  lib,
  stdenv,
  fetchurl,
  testers,
  static ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libjpeg";
  version = "10";

  src = fetchurl {
    url = "https://www.ijg.org/files/jpegsrc.v${finalAttrs.version}.tar.gz";
    hash = "sha256-i56qEyQmkOvQPhcoqx7fl6gaeO1ug2JNSTZV8xrJWrU=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
  ];

  configureFlags = lib.optional static "--enable-static --disable-shared";
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Library that implements the JPEG image file format";
    homepage = "https://www.ijg.org/";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libjpeg" ];
  };
})
