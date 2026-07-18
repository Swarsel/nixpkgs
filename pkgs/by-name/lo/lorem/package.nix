{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
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
  pname = "lorem";
  version = "1.6";

  src = fetchFromGitLab {
    owner = "design";
    repo = "lorem";
    rev = finalAttrs.version;
    hash = "sha256-DY2UVB6N3vQehDm1s3KIjodUfyWu3QBo6NxWlPswDN4=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  nativeBuildInputs = [
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
    glib
    gtk4
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-DE0jzI9Tmusm6VT19PsmJoTYHQ4fjrg3ik6tAWhMVSA=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Generate placeholder text";
    homepage = "https://apps.gnome.org/Lorem/";
    changelog = "https://gitlab.gnome.org/World/design/lorem/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lorem";
    teams = [ lib.teams.gnome-circle ];
  };
})
