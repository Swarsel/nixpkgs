{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  desktop-file-utils,
  glib,
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
  pname = "distroshelf";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "ranfdev";
    repo = "DistroShelf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4rNdp0g/QaiLnKGC4baYAq29dxluyZ+9TgeBlqidRp0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
    desktop-file-utils
    pkg-config
  ];

  buildInputs = [
    glib
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-5luI46rSgB+N0OKQzSopEhCCEnwAhMabRit9MtsSSVA=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI for Distrobox Containers";
    homepage = "https://github.com/ranfdev/DistroShelf";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "distroshelf";
  };
})
