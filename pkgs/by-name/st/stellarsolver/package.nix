{
  lib,
  stdenv,
  fetchFromGitHub,
  cfitsio,
  cmake,
  gsl,
  qt6,
  wcslib,
  withTester ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "stellarsolver";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "rlancaste";
    repo = "stellarsolver";
    rev = finalAttrs.version;
    sha256 = "sha256-bc/IkPg5IhkZ0Y5fOlyDi/m+ibHciaaaeC8KWrhkdi0=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    qt6.qtbase
    cfitsio
    gsl
    wcslib
  ];

  cmakeFlags = [
    (lib.strings.cmakeBool "BUILD_TESTER" withTester)
    (lib.strings.cmakeBool "USE_QT5" false)
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Astrometric plate solving library";
    homepage = "https://github.com/rlancaste/stellarsolver";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      returntoreality
    ];

    platforms = lib.platforms.unix;
  };
})
