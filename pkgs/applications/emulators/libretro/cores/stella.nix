{
  lib,
  fetchFromGitHub,
  mkLibretroCore,
}:
mkLibretroCore {
  version = "0-unstable-2026-06-28";

  src = fetchFromGitHub {
    owner = "stella-emu";
    repo = "stella";
    rev = "62522a804dec6b5aa683fa5e37f5f6c48aefded1";
    hash = "sha256-YALzsYJwZDtVkVx9yvkkEZ1AHxT4fAc+epoFDwStmSI=";
  };

  preBuild = "cd src/os/libretro";
  core = "stella";
  dontConfigure = true;
  makefile = "Makefile";

  meta = {
    description = "Port of Stella to libretro";
    homepage = "https://github.com/stella-emu/stella";
    license = lib.licenses.gpl2Only;
  };
}
