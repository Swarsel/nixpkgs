{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  gtk3-x11,
  pkg-config,
  protobuf,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cdogs-sdl";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "cxong";
    repo = "cdogs-sdl";
    tag = finalAttrs.version;
    hash = "sha256-588bPis3n9BZnEywLmgouRgpiEvB+sKp6/xhUDhfddQ=";
  };

  postPatch = ''
    patchShebangs src/proto/nanopb/generator/*
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    (python3.withPackages (
      pp: with pp; [
        pp.protobuf
        setuptools
      ]
    ))
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    gtk3-x11
    protobuf
  ];

  cmakeFlags = [
    "-DCDOGS_DATA_DIR=${placeholder "out"}/"
    "-DCMAKE_C_FLAGS=-Wno-error=array-bounds"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=stringop-overflow"
  ];

  # inlining failed in call to 'tinydir_open': --param max-inline-insns-single limit reached
  hardeningDisable = [ "fortify3" ];

  meta = {
    description = "Open source classic overhead run-and-gun game";
    homepage = "https://cxong.github.io/cdogs-sdl";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/cdogs-sdl.x86_64-darwin
  };
})
