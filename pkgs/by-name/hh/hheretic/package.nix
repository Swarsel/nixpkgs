{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  SDL_mixer,
  autoreconfHook,
  gitUpdater,
  libGL,
  libGLU,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hheretic";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "sezero";
    repo = "hheretic";
    rev = "hheretic-${finalAttrs.version}";
    hash = "sha256-49eQeh0suU+7QLB25cvrqirZRaBgZp438H6NW0pWsPI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    (lib.getDev SDL)
  ];

  buildInputs = [
    SDL
    SDL_mixer
    libGL
    libGLU
  ];

  configureFlags = [ "--with-audio=sdlmixer" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 hheretic-gl -t $out/bin

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "hheretic-";
  };

  meta = {
    inherit (SDL.meta) platforms;
    description = "Linux port of Raven Game's Heretic";
    homepage = "https://hhexen.sourceforge.net/hhexen.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ moody ];
    mainProgram = "hheretic-gl";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
