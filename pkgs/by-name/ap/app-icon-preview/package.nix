{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  libadwaita,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "app-icon-preview";
  version = "3.5.1";

  src = fetchFromGitLab {
    owner = "design";
    repo = "app-icon-preview";
    tag = finalAttrs.version;
    hash = "sha256-sfQFmQ27JUu92ArCi1dTnD3sWoUl/0tJguMvR1BoK/Q=";
    domain = "gitlab.gnome.org";
    forceFetchGit = true;
    group = "World";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libxml2
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-WGzXjIgZBwuBbSWK+EWDMW2kfqeoYHMsP4TXglR2Sc4=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for designing applications icons";
    homepage = "https://gitlab.gnome.org/World/design/app-icon-preview";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = lib.platforms.linux;
    mainProgram = "app-icon-preview";
  };
})
