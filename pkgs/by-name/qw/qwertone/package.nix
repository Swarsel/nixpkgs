{
  lib,
  fetchFromGitLab,
  alsa-lib,
  atk,
  gtk3,
  pkg-config,
  rustPlatform,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qwertone";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "azymohliad";
    repo = "qwertone";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GD7iFDAaS6D7DGPvK+Cof4rVbUwPX9aCI1jfc0XTxn8=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    atk
    gtk3
  ];

  cargoHash = "sha256-5hrjmX+eUPrj48Ii1YHPZFPMvynowSwSArcNnUOw4hc=";

  meta = {
    description = "Simple music synthesizer app based on usual qwerty-keyboard for input";
    homepage = "https://gitlab.com/azymohliad/qwertone";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.linux;
    mainProgram = "qwertone";
  };
})
