{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_mixer,
  fetchpatch,
  libGLU,
  libconfig,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "MAR1D";
  version = "unstable-2023-02-02";

  src = fetchFromGitHub {
    owner = "Radvendii";
    repo = "MAR1D";
    rev = "fa5dc36e1819a15539ced339ad01672e5a498c5c";
    hash = "sha256-kZERhwnTpBhjx6MLdf1bYCWMjtTiId/5a69kRt+/6oY=";
  };

  patches = [
    # Fix the build on Darwin.
    # https://github.com/Radvendii/MAR1D/pull/4
    (fetchpatch {
      hash = "sha256-ybdLA2sO8e0J7w4roSdMWn72OkttD3y+cJ3ScuGiHCI=";
      url = "https://github.com/Radvendii/MAR1D/commit/baf3269e90eca69f154a43c4c1ef14677a6300fd.patch";
    })
    # https://github.com/Radvendii/MAR1D/pull/5
    ./fix-aarch64.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    libconfig
    libGLU
  ];

  env = {
    NIXPKGS_CFLAGS_COMPILE = toString [
      "-Wno-error=array-parameter"
    ];
  };

  meta = {
    description = "First person Super Mario Bros";

    longDescription = ''
      The original Super Mario Bros as you've never seen it. Step into Mario's
      shoes in this first person clone of the classic Mario game. True to the
      original, however, the game still takes place in a two dimensional world.
      You must view the world as mario does, as a one dimensional line.
    '';

    homepage = "https://mar1d.com";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ taeer ];
    platforms = lib.platforms.unix;
    mainProgram = "MAR1D";
  };
})
