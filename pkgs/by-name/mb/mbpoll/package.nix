{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libmodbus,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mbpoll";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "epsilonrt";
    repo = "mbpoll";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rO3j/p7MABlxcwRAZm26u7wgODGFTtetSDhPWPzTuEA=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-QwrfNeGbirYSrXvGI1lItwNBDN2d6VDF8yjvgcGELxE=";
      name = "cmake4-fix";
      url = "https://github.com/epsilonrt/mbpoll/commit/baad0efca89f0d8fe370591283d87a6e8e7dee4c.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libmodbus ];

  meta = {
    description = "Command line utility to communicate with ModBus slave (RTU or TCP)";
    homepage = "https://epsilonrt.fr";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "mbpoll";
  };
})
