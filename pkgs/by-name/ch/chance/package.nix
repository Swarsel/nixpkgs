{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
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
  pname = "chance";
  version = "4.0.1";

  src = fetchFromGitLab {
    owner = "zelikos";
    repo = "rollit";
    tag = finalAttrs.version;
    hash = "sha256-25+/TvTba/QF7+QE8+O7u4yc9BNi0pcZeNj11dGkEfg=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-ObT3l/Exk6UzUGmzCed7mJ7hVzg8CsQIT3fe1RIUfIM=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dice roller built using GTK4 and libadwaita";
    homepage = "https://gitlab.com/zelikos/rollit";
    changelog = "https://gitlab.com/zelikos/rollit/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Guanran928 ];
    platforms = lib.platforms.linux;
    mainProgram = "rollit";
  };
})
