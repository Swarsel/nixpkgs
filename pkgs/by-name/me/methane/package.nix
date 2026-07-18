{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  alsa-lib,
  clanlib,
  fontconfig,
  freealut,
  gettext,
  libGL,
  libGLU,
  libglut,
  libmikmod,
  libxinerama,
  libxrender,
  nix-update-script,
  openal,
  pkg-config,
  quesoglc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "methane";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "rombust";
    repo = "methane";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rByJqkhYsRuv0gTug+vP2qgkRY8TnX+Qx4/MbAmPTOU=";
  };

  nativeBuildInputs = [
    gettext
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    fontconfig
    freealut
    libglut
    libGL
    libGLU
    openal
    quesoglc
    clanlib
    libxrender
    libxinerama
    libmikmod
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/ $out/share/methane/ $out/share/docs/
    cp methane $out/bin
    cp -r resources/* $out/share/methane/.
    cp -r docs/* $out/share/docs/.
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Clone of Taito's Bubble Bobble arcade game released for Amiga in 1993 by Apache Software";
    homepage = "https://github.com/rombust/methane";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "methane";
  };
})
