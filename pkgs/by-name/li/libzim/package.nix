{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  icu,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  xapian,
  xz,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzim";
  version = "9.8.0";

  src = fetchFromGitHub {
    owner = "openzim";
    repo = "libzim";
    tag = finalAttrs.version;
    hash = "sha256-7AfhDpNuEGsb2ys4Lq+VEPI5sVZJ4Md0G6uLcuRKbtE=";
  };

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
    python3
  ];

  buildInputs = [
    icu
    zstd
  ];

  propagatedBuildInputs = [
    xapian
    xz
  ];

  mesonFlags = [
    # Tests are located at https://github.com/openzim/zim-testing-suite
    # "...some tests need up to 16GB of memory..."
    "-Dtest_data_dir=none"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reference implementation of the ZIM specification";
    homepage = "https://github.com/openzim/libzim";
    changelog = "https://github.com/openzim/libzim/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      fab
      greg
    ];
  };
})
