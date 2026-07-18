{
  lib,
  fetchFromGitHub,
  mkLibretroCore,
}:
mkLibretroCore rec {
  version = "0-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "libretro-atari800";
    rev = "3f036fd69a0f0948d32a9a7cd97af3e0dd7ec434";
    hash = "sha256-WnozEFNpW6qmSsQGTKzflitG6TVaozyOMcnAka+E1fE=";
  };

  makeFlags = [ "GIT_VERSION=${builtins.substring 0 7 src.rev}" ];
  core = "atari800";
  makefile = "Makefile";

  meta = {
    description = "Port of Atari800 to libretro";
    homepage = "https://github.com/libretro/libretro-atari800";
    license = lib.licenses.gpl2Only;
  };
}
