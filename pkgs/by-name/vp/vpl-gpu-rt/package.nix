{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libdrm,
  libva,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vpl-gpu-rt";
  version = "26.1.6";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "vpl-gpu-rt";
    rev = "intel-onevpl-${finalAttrs.version}";
    hash = "sha256-E8CQC2jHSo2ZHp8drXXTgcOOHru3kDJtoLNKwm++YG8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libva
  ];

  meta = {
    description = "oneAPI Video Processing Library Intel GPU implementation";
    homepage = "https://github.com/intel/vpl-gpu-rt";
    changelog = "https://github.com/intel/vpl-gpu-rt/releases/tag/${finalAttrs.src.rev}";
    license = [ lib.licenses.mit ];

    maintainers = with lib.maintainers; [
      evanrichter
      pjungkamp
    ];

    platforms = [ "x86_64-linux" ];
  };
})
