{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  gtksourceview5,
  libadwaita,
  libpanel,
  meson,
  ninja,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "typewriter";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "JanGernert";
    repo = "typewriter";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-c4wh59RNYMyK1rwoxzjhDCtnGnAxGABAu5cugV3P0zU=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    blueprint-compiler
    desktop-file-utils
    appstream-glib
  ];

  buildInputs = [
    openssl
    libadwaita
    libpanel
    gtksourceview5
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-YvzVpSAPORxjvbGQqRK1V8DKcF12NUOGOgmegJSODQc=";
  };

  meta = {
    description = "Create documents with typst";
    homepage = "https://gitlab.gnome.org/JanGernert/typewriter";
    changelog = "https://gitlab.gnome.org/JanGernert/typewriter/-/releases/v.${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.da157 ];
    platforms = lib.platforms.linux;
    mainProgram = "typewriter";
  };
})
