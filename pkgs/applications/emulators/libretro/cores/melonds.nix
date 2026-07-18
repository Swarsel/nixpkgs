{
  lib,
  fetchFromGitHub,
  libGL,
  libGLU,
  mkLibretroCore,
}:
mkLibretroCore {
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "melonds";
    rev = "c9550d18923fe86a5ad9faa159399b55c12b47f1";
    hash = "sha256-xvBdt/TMxZOrC//DLHRWRMqIibt7dNsfLM/FeMTRA60=";
  };

  core = "melonds";

  extraBuildInputs = [
    libGLU
    libGL
  ];

  makefile = "Makefile";

  meta = {
    description = "Port of MelonDS to libretro";
    homepage = "https://github.com/libretro/melonds";
    license = lib.licenses.gpl3Only;
  };
}
