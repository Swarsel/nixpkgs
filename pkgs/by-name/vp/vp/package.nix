{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  autoreconfHook,
  libx11,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vp";
  version = "1.8-unstable-2025-09-15";

  src = fetchFromGitHub {
    owner = "erikg";
    repo = "vp";
    rev = "12ab0c49a7d837af8370b91d3f6e4fa11789e57a";
    hash = "sha256-Ea1p9NLk7tW3elU0zmlPAkobyv+yLYeKv5hscJTFJhs=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_image
    libx11
  ];

  # gcc15 build failure
  env.NIX_CFLAGS_COMPILE = toString [ "-std=gnu17" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    inherit (SDL2.meta) platforms;
    description = "SDL based picture viewer/slideshow";
    homepage = "https://github.com/erikg/vp";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "vp";
    hydraPlatforms = lib.platforms.linux; # build hangs on both Darwin platforms, needs investigation
  };
})
