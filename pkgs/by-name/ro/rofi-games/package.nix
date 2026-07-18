{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cargo,
  glib,
  just,
  pango,
  pkg-config,
  rofi,
  rustPlatform,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-games";
  version = "1.16.2";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "rofi-games";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LwzlBjRh9YdUGBl9+L3Vdetmy7lUdAIvjKvp8hSebvY=";
  };

  patches = [
    # fix the install locations of files and set default just task
    ./fix-justfile.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    just
    rofi
    pkg-config
  ];

  buildInputs = [
    glib
    cairo
    pango
    sqlite
  ];

  env.PKGDIR = placeholder "out";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-opImhuLXj3/TtpmBjjMvrcdHalxYFyv5QZ0V8poYH7U=";
  };

  meta = {
    description = "Rofi plugin which adds a mode that will list available games for launch along with their box art";
    homepage = "https://github.com/Rolv-Apneseth/rofi-games";
    changelog = "https://github.com/Rolv-Apneseth/rofi-games/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux;
  };
})
