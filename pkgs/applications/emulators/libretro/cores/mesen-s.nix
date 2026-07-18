{
  lib,
  fetchFromGitHub,
  mkLibretroCore,
}:
mkLibretroCore {
  version = "0-unstable-2026-04-20";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "mesen-s";
    rev = "1d475abd174d16ecb1fb030961ff26076ab51ee6";
    hash = "sha256-JSXkh6OyclYl3X/sJLRZsb5sdbSfanbJAKlhaFFjSrI=";
  };

  preBuild = "cd Libretro";
  core = "mesen-s";
  makefile = "Makefile";
  normalizeCore = false;

  meta = {
    description = "Port of Mesen-S to libretro";
    homepage = "https://github.com/libretro/mesen-s";
    license = lib.licenses.gpl3Only;
  };
}
