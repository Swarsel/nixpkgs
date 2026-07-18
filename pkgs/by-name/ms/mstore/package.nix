{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  mctc-lib,
  meson,
  ninja,
  pkg-config,
  python3,
  buildType ? "meson",
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "mstore";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "mstore";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zfrxdrZ1Um52qTRNGJoqZNQuHhK3xM/mKfk0aBLrcjw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix wrong generation of package config include paths
    ./pkgconfig.patch
  ];

  postPatch = ''
    patchShebangs --build config/install-mod.py
  '';

  nativeBuildInputs = [
    gfortran
    pkg-config
    python3
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optional (buildType == "cmake") cmake;

  buildInputs = [ mctc-lib ];

  meta = {
    description = "Molecular structure store for testing";
    homepage = "https://github.com/grimme-lab/mstore";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
