{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  blas,
  cmake,
  gfortran,
  lapack,
  # propagatedBuildInputs
  mctc-lib,
  meson,
  ninja,
  nix-update-script,
  numsa,
  pkg-config,
  python3,
  test-drive,
  toml-f,
  buildType ? "meson",
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);
stdenv.mkDerivation (finalAttrs: {
  pname = "cpcm-x";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "CPCM-X";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FyPUECbcqUHoGq1LASvPF4qSUKQ5N/y1itq8e2wGliE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # The installed CMake package config links numsa::numsa transitively but
    # never re-discovers it, so consumers fail with "target numsa::numsa not
    # found". Add the missing find_dependency call.
    ./cmake-config-find-numsa.patch
  ];

  postPatch = ''
    substituteInPlace config/install-mod.py \
      --replace-fail "/usr/bin/env python" "${lib.getExe python3}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gfortran
    pkg-config
    python3
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optionals (buildType == "cmake") [
    cmake
  ];

  buildInputs = [
    blas
    lapack
    # only needed to build the bundled test suite
    test-drive
  ];

  propagatedBuildInputs = [
    mctc-lib
    numsa
    toml-f
  ];

  doCheck = true;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extended conductor-like polarizable continuum solvation model";
    homepage = "https://github.com/grimme-lab/CPCM-X";
    changelog = "https://github.com/grimme-lab/CPCM-X/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
    mainProgram = "cpx";
  };
})
