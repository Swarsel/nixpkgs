{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  jonquil,
  meson,
  ninja,
  openmpCheckPhaseHook,
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
  pname = "mctc-lib";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "mctc-lib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rlwUNeuLzgSWZXDKCFS/H82+oH23tEzhhILqC/ZV6PI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Allow dynamically linked jonquil as dependency. That then additionally
    # requires linking in toml-f
    ./meson.patch

    # Fix wrong generation of package config include paths
    ./cmake.patch
  ];

  postPatch = ''
    patchShebangs --build config/install-mod.py
  '';

  nativeBuildInputs = [
    gfortran
    pkg-config
    python3
    openmpCheckPhaseHook
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optional (buildType == "cmake") cmake;

  propagatedBuildInputs = [
    # jonquil (and the toml-f it propagates) appears in mctc-lib.pc's Requires.private, so it must
    # be propagated for pkg-config consumers (e.g. dftd4) to resolve mctc-lib
    jonquil
  ];

  doCheck = true;

  meta = {
    description = "Modular computation tool chain library";
    homepage = "https://github.com/grimme-lab/mctc-lib";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "mctc-convert";
  };
})
