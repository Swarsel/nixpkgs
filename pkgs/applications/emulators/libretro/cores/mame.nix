{
  lib,
  fetchFromGitHub,
  alsa-lib,
  libGL,
  libGLU,
  mkLibretroCore,
  python3,
}:
mkLibretroCore {
  version = "0-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "mame";
    rev = "0108c5ef3a2261a20c54186ce76cfb4d9ea384a4";
    hash = "sha256-O/L6+JFCOZtRec40S4xMaKh7A8HteZ5L8GQjrhhRfUw=";
    fetchSubmodules = true;
  };

  # Setting this is breaking compilation of src/3rdparty/genie for some reason
  makeFlags = [ "ARCH=" ];
  core = "mame";

  extraBuildInputs = [
    alsa-lib
    libGLU
    libGL
  ];

  extraNativeBuildInputs = [ python3 ];

  meta = {
    description = "Port of MAME to libretro";
    homepage = "https://github.com/libretro/mame";

    license = with lib.licenses; [
      bsd3
      gpl2Plus
    ];
  };
}
