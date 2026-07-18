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
  pname = "hhexen";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "sezero";
    repo = "hhexen";
    rev = "hhexen-${finalAttrs.version}";
    hash = "sha256-D1gIdIqb6RN7TA7ezbBhy2Z82TH1quN8kgAMNRHMfhw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    (lib.getDev SDL)
  ];

  buildInputs = [
    libGL
    libGLU
    SDL
    SDL_mixer
  ];

  configureFlags = [ "--with-audio=sdlmixer" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 hhexen-gl -t $out/bin

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "hhexen-";
  };

  meta = {
    inherit (SDL.meta) platforms;
    description = "Linux port of Raven Game's Hexen";
    homepage = "https://hhexen.sourceforge.net/hhexen.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      moody
      djanatyn
    ];

    mainProgram = "hhexen-gl";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
