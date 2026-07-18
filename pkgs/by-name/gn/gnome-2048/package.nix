{
  lib,
  stdenv,
  fetchurl,
  cargo,
  desktop-file-utils,
  gnome,
  gtk4,
  itstool,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  vala,
  wrapGAppsHook4,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-2048";
  version = "50.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-2048/${lib.versions.major finalAttrs.version}/gnome-2048-${finalAttrs.version}.tar.xz";
    hash = "sha256-bRXfaKYSjPDJnlmJCK+MZntzPcQAPvTSHUtMSkK9Lak=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    itstool
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    rustc
    cargo
    desktop-file-utils
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  doCheck = true;

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    rustPlatform.cargoCheckHook
  ];

  __structuredArgs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-OcuhISJhm8uvcJjki86FSNiT5AoqUrILZaHcn1oZVtk=";
  };

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-2048";
    };
  };

  meta = {
    description = "Obtain the 2048 tile";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-2048";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-2048/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-2048";
    teams = [ lib.teams.gnome ];
  };
})
