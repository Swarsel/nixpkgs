{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation {
  pname = "loguru";
  version = "2.1.0-unstable-2023-04-06";

  src = fetchFromGitHub {
    owner = "emilk";
    repo = "loguru";
    rev = "4adaa185883e3c04da25913579c451d3c32cfac1";
    hash = "sha256-NpMKyjCC06bC5B3xqgDr2NgA9RsPEeiWr9GbHrHHzZ8=";
  };

  patches = [
    # See https://github.com/emilk/loguru/issues/249
    # The following patches are coming from a fork and fix builds on Darwin
    # Hopefully they will be merged in the main repository soon.
    (fetchpatch {
      hash = "sha256-fYdS8+qfgyj1J+T6H434jDGK/L+VYq+L22CQ7M/uiXE=";
      url = "https://github.com/virtuosonic/loguru/commit/e1ffdc4149083cc221d44b666a0f7e3ec4a87259.patch";
    })
    (fetchpatch {
      hash = "sha256-3FhH7zdkzHuXSirSCr8A3uHg8UpSfEM02AkR0ZSG0Yw=";
      url = "https://github.com/virtuosonic/loguru/commit/743777bea361642349d4673e6a0a55912849c14f.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DLOGURU_WITH_STREAMS=1"
  ];

  meta = {
    description = "Lightweight C++ logging library";
    homepage = "https://github.com/emilk/loguru";
    license = lib.licenses.unlicense;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
