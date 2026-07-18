{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  testers,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openjph";
  version = "0.24.1";

  src = fetchFromGitHub {
    owner = "aous72";
    repo = "openjph";
    rev = finalAttrs.version;
    hash = "sha256-4TodVzVK86UCrD1Q6EzIjsJhyOFQUryQHZmQ2DrXVTg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    validatePkgConfig
  ];

  cmakeFlags = [
    (lib.cmakeBool "OJPH_ENABLE_TIFF_SUPPORT" false)
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K)";
    homepage = "https://openjph.org/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ abustany ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "openjph" ];
  };
})
