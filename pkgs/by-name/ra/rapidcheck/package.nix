{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rapidcheck";
  version = "0-unstable-2023-12-14";

  src = fetchFromGitHub {
    owner = "emil-e";
    repo = "rapidcheck";
    rev = "ff6af6fc683159deb51c543b065eba14dfcf329b";
    hash = "sha256-Ixz5RpY0n8Un/Pv4XoTfbs40+70iyMbkQUjDqoLaWOg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "RC_INSTALL_ALL_EXTRAS" true)
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = unstableGitUpdater { };
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "C++ framework for property based testing inspired by QuickCheck";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.all;

    pkgConfigModules = [
      "rapidcheck"
      # Extras
      "rapidcheck_boost"
      "rapidcheck_boost_test"
      "rapidcheck_catch"
      "rapidcheck_doctest"
      "rapidcheck_gtest"
    ];
  };
})
