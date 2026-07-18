{
  lib,
  fetchFromGitHub,
  libGL,
  libGLU,
  mkLibretroCore,
  withHw ? false,
}:
mkLibretroCore {
  version = "0-unstable-2026-07-11";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "beetle-psx-libretro";
    rev = "004268513bb56655fff358b8caee88503a141776";
    hash = "sha256-47US8cQ0efhlTao8aW31yOdK/aGtWikYAtsAjQi83y4=";
  };

  makeFlags = [
    "HAVE_HW=${if withHw then "1" else "0"}"
    "HAVE_LIGHTREC=1"
  ];

  core = "mednafen-psx" + lib.optionalString withHw "-hw";

  extraBuildInputs = lib.optionals withHw [
    libGL
    libGLU
  ];

  makefile = "Makefile";

  meta = {
    description =
      "Port of Mednafen's PSX Engine core to libretro"
      + lib.optionalString withHw " (with hardware acceleration support)";

    homepage = "https://github.com/libretro/beetle-psx-libretro";
    license = lib.licenses.gpl2Only;
  };
}
