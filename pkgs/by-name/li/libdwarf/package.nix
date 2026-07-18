{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdwarf";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    tag = "v${finalAttrs.version}";
    hash = "sha256-65jEnM+eJ7HnZlpEM2D67W0Xgb9B/aa4JhajowG0Z8o=";
  };

  outputs = [
    "bin"
    "lib"
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    zlib
    zstd
  ];

  meta = {
    description = "Library for reading DWARF2 and later DWARF";
    homepage = "https://github.com/davea42/libdwarf-code";
    changelog = "https://github.com/davea42/libdwarf-code/releases/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
    platforms = lib.platforms.unix;
    mainProgram = "dwarfdump";
  };
})
