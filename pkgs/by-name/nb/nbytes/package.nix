{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  nix-update-script,
  testers,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nbytes";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "nbytes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-etCRWjak7tKL6dKlQR7SD6HXx/mn/8gnR4l+CAjoQgA=";
  };

  nativeBuildInputs = [
    cmake
    validatePkgConfig
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "NBYTES_ENABLE_TESTING" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Library of byte handling functions extracted from Node.js core";
    homepage = "https://github.com/nodejs/nbytes";
    changelog = "https://github.com/nodejs/nbytes/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aduh95 ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "nbytes" ];
  };
})
