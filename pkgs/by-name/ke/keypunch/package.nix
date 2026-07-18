{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  gettext,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keypunch";
  version = "6.3";

  src = fetchFromGitHub {
    owner = "bragefuglseth";
    repo = "keypunch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NjPC7WbzOk0tDjM8la+TKGy+U2NNT2kwcrSkaG7TylQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc

    meson
    ninja

    pkg-config
    appstream
    blueprint-compiler
    desktop-file-utils
    gettext

    wrapGAppsHook4
  ];

  buildInputs = [ libadwaita ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-gQg6CCb5OzK2fLWMtkRTv1hK642IezRN+5qLMGVV6s8=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Practice your typing skills";
    homepage = "https://github.com/bragefuglseth/keypunch";
    changelog = "https://github.com/bragefuglseth/keypunch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      tomasajt
      getchoo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "keypunch";
    teams = [ lib.teams.gnome-circle ];
  };
})
