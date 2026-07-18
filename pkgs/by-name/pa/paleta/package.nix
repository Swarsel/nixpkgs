{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "paleta";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "nate-xyz";
    repo = "paleta";
    rev = "v${version}";
    hash = "sha256-c+X49bMywstRg7cSAbbpG/vd8OUB7RhdQVRumTIBDDk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-RuzqU06iyK+IN7aO+Lq/IaRLh2oFpWM1rz69Koiicgg=";
  };

  meta = {
    description = "Extract the dominant colors from any image";
    homepage = "https://github.com/nate-xyz/paleta";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "paleta";
  };
}
