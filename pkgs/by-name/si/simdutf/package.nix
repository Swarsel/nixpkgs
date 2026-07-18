{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libiconv,
  nix-update-script,
  testers,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simdutf";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "simdutf";
    repo = "simdutf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-psMMF26+nTwdbtPfFFE3fXkatrh9Bp9qMsrdI/FmrDg=";
  };

  nativeBuildInputs = [
    cmake
    validatePkgConfig
  ];

  buildInputs = [
    libiconv
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Unicode routines validation and transcoding at billions of characters per second";
    homepage = "https://github.com/simdutf/simdutf";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "simdutf" ];
  };
})
