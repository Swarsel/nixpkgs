{
  lib,
  fetchFromGitHub,
  SDL2,
  SDL2_gfx,
  build-idris-package,
  effects,
  pkg-config,
}:
build-idris-package rec {
  pname = "sdl2";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "steshaw";
    repo = "idris-sdl2";
    rev = version;
    sha256 = "1jslnlzyw04dcvcd7xsdjqa7waxzkm5znddv76sv291jc94xhl4a";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  extraBuildInputs = [
    SDL2
    SDL2_gfx
  ];

  idrisDeps = [ effects ];
  prePatch = "patchShebangs .";

  meta = {
    description = "SDL2 binding for Idris";
    homepage = "https://github.com/steshaw/idris-sdl2";

    maintainers = with lib.maintainers; [
      brainrape
      steshaw
    ];
  };
}
