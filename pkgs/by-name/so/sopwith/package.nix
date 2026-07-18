{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoreconfHook,
  glib,
  libGL,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sopwith";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "fragglet";
    repo = "sdl-sopwith";
    tag = "sdl-sopwith-${finalAttrs.version}";
    hash = "sha256-s7npLid3GYZArQmctSwOu8zeC+mSfTiiiOaOEa9dcrg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    SDL2
    libGL
  ];

  meta = {
    description = "Classic biplane shoot ‘em-up game";
    homepage = "https://github.com/fragglet/sdl-sopwith";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ evilbulgarian ];
    platforms = lib.platforms.unix;
    mainProgram = "sopwith";
  };
})
