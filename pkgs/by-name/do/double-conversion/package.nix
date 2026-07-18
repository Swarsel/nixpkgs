{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  ninja,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "double-conversion";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "double-conversion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gxaPqQ51RyXZaTHkvh4RBpedPopcRiuWDoT+PPbI1uw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    ctestCheckHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" stdenv.hostPlatform.hasSharedLibraries)
  ];

  # Case sensitivity issue
  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    rm BUILD
  '';

  doCheck = true;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Binary-decimal and decimal-binary routines for IEEE doubles";
    homepage = "https://github.com/google/double-conversion";
    changelog = "https://github.com/google/double-conversion/blob/${finalAttrs.src.tag}/Changelog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fzakaria ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    pkgConfigModules = [ "double-conversion" ];
  };
})
