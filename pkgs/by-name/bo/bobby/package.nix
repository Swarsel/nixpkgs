{
  lib,
  stdenv,
  fetchFromGitHub,
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
  sqlite,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bobby";
  version = "50.0.2";

  src = fetchFromGitHub {
    owner = "hbons";
    repo = "bobby";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/N7CmzPwUdGkHIZujCGW3LvsGM6DdXrcm2kH6XlVGDA=";
  };

  # favor sqlite from nixpkgs instead of a vendored variant in rusqlite
  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail ', features = ["bundled"]' ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    desktop-file-utils # for `update-desktop-database`
    gtk4 # for `gtk-update-icon-cache`
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4 # fix error: GLib-GIO-ERROR **: No GSettings schemas are installed on the system
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    sqlite
  ];

  doCheck = true;
  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-TT3ceAy44sfyKZ7wmH3C4nj5TyfiJlu4vBWAaGs+pGg=";
  };

  mesonCheckFlags = [
    "--print-errorlogs"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Browse SQLite files";
    homepage = "https://apps.gnome.org/Bobby/";
    changelog = "https://github.com/hbons/Bobby/blob/${finalAttrs.src.tag}/data/studio.planetpeanut.Bobby.metainfo.xml";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aiyion
    ];

    mainProgram = "bobby";
    donationPage = "https://planetpeanut.studio/sponsors";
    teams = [ lib.teams.gnome-circle ];
  };
})
