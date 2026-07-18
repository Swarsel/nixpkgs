{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  which,
  enableStatic ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rhash";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "rhash";
    repo = "RHash";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9/kFI38PG3AKsdDqEV/wEzSel9IlQQ/pvOyhU/N/aV0=";
  };

  nativeBuildInputs = [ which ];
  buildInputs = lib.optionals stdenv.hostPlatform.isFreeBSD [ gettext ];

  configureFlags = [
    "--ar=${stdenv.cc.targetPrefix}ar"
    "--target=${stdenv.hostPlatform.config}"
    "--disable-shani"
    (lib.enableFeature enableStatic "static")
    (lib.enableFeature enableStatic "lib-static")
  ];

  doCheck = true;
  checkTarget = "test-full";
  configurePlatforms = [ ];
  # configure script is not autotools-based, doesn't support these options
  dontAddStaticConfigureFlags = true;

  installTargets = [
    "install"
    "install-lib-headers"
  ]
  ++ lib.optionals (!enableStatic) [
    "install-lib-so-link"
  ];

  meta = {
    description = "Console utility and library for computing and verifying hash sums of files";
    homepage = "https://rhash.sourceforge.net/";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
