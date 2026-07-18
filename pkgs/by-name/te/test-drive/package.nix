{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  meson,
  mesonEmulatorHook,
  ninja,
  buildType ? "meson",
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "test-drive";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "fortran-lang";
    repo = "test-drive";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xRx8ErIN9xjxZt/nEsdIQkIGFRltuELdlI8lXA+M030=";
  };

  patches = [
    # Fix wrong generation of package config include paths
    ./cmake.patch
  ];

  nativeBuildInputs = [
    gfortran
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optional (buildType == "cmake") cmake
  ++ lib.optional (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) mesonEmulatorHook;

  mesonAutoFeatures = "auto";

  meta = {
    description = "Procedural Fortran testing framework";
    homepage = "https://github.com/fortran-lang/test-drive";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
