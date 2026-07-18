{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  meson,
  ninja,
  pkg-config,
  test-drive,
  buildType ? "meson",
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "toml-f";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "toml-f";
    repo = "toml-f";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lReez2rSAJVnLFngjUYgGkm+HUDH8VsCC2m9zYOOr4A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix wrong generation of package config include paths
    ./cmake.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gfortran
    pkg-config
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optionals (buildType == "cmake") [
    cmake
  ];

  buildInputs = [ test-drive ];

  cmakeFlags = [
    "-Dtest-drive_DIR=${test-drive}"
  ];

  # tftest-build fails on aarch64-linux
  doCheck = !stdenv.hostPlatform.isAarch64;
  __structuredAttrs = true;

  meta = {
    description = "TOML parser implementation for data serialization and deserialization in Fortran";
    homepage = "https://github.com/toml-f/toml-f";
    changelog = "https://github.com/toml-f/toml-f/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
