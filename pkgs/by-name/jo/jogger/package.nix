{
  lib,
  stdenv,
  alsa-lib,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  espeak,
  fetchFromCodeberg,
  glib-networking,
  libadwaita,
  libshumate,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jogger";
  version = "1.2.5";

  src = fetchFromCodeberg {
    owner = "baarkerlounger";
    repo = "jogger";
    tag = finalAttrs.version;
    hash = "sha256-bju9XXMT6HRHG9QViO+FQCYQ+llrC+GP/AlIha0mxkM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    libshumate
    alsa-lib
    espeak
    sqlite
    glib-networking
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-k4nUtFdwCWa8flSkOEQe7UqorpYPCGrcXHTvVOqoAQI=";
  };

  meta = {
    description = "App for Gnome Mobile to Track running and other workouts";
    homepage = "https://codeberg.org/baarkerlounger/jogger";

    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];

    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "jogger";
  };
})
