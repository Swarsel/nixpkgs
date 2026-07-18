{
  lib,
  stdenv,
  SDL2,
  SDL2_gfx,
  SDL2_image,
  SDL2_mixer,
  SDL2_net,
  SDL2_ttf,
  fetchgit,
  gitUpdater,
  python3,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tennix";
  version = "1.3.4";

  src = fetchgit {
    url = "git://repo.or.cz/tennix.git";
    tag = "tennix-${finalAttrs.version}";
    hash = "sha256-siGfnpZPMYMTgYzaPVhNXEuA/OSWmEl891cLhvgGr7o=";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [
    python3
    SDL2
    SDL2_gfx
    SDL2_mixer
    SDL2_image
    SDL2_ttf
    SDL2_net
  ];

  configurePhase = ''
    runHook preConfigure

    ./configure --prefix $out

    runHook postConfigure
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "tennix-"; };

  meta = {
    description = "Classic Championship Tour 2011";
    homepage = "https://icculus.org/tennix/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "tennix";
  };
})
