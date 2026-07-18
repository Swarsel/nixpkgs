{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  desktop-file-utils,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "share-preview";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "share-preview";
    rev = finalAttrs.version;
    hash = "sha256-6Pk+3o4ZWF5pDYAtcBgty4b7edzIZnIuJh0KW1VW33I=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    openssl
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [ "-Wno-error=incompatible-function-pointer-types" ]
  );

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-MC5MsoFdeCvF9nIFoYCKoBBpgGysBH36OdmTqbIJt8s=";
    name = "share-preview-${finalAttrs.version}";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Preview and debug websites metadata tags for social media share";
    homepage = "https://apps.gnome.org/SharePreview";
    changelog = "https://github.com/rafaelmardojai/share-preview/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "share-preview";
    downloadPage = "https://github.com/rafaelmardojai/share-preview";
    teams = [ lib.teams.gnome-circle ];
  };
})
