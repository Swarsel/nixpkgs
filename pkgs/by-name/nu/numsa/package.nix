{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  asciidoctor,
  blas,
  # cmake:
  cmake,
  gfortran,
  lapack,
  # propagatedBuildInputs
  mctc-lib,
  # meson:
  meson,
  # buildInputs
  mstore,
  ninja,
  # passthru
  nix-update-script,
  pkg-config,
  python3,
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
  pname = "numsa";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "numsa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PAzxeYyg/9P/3YFxKzM4ZFm2xT0AGap6q8/ei8jD/3M=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Use nixpkgs' mstore instead of building it from source
    ./use-external-mstore.patch
  ];

  postPatch = ''
    substituteInPlace config/install-mod.py \
      --replace-fail "/usr/bin/env python" "${lib.getExe python3}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoctor
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
    mstore # only needed to build the bundled test suite
    test-drive
  ];

  propagatedBuildInputs = [
    mctc-lib
  ];

  doCheck = true;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Solvent accessible surface area calculation";
    homepage = "https://github.com/grimme-lab/numsa";
    changelog = "https://github.com/grimme-lab/numsa/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
