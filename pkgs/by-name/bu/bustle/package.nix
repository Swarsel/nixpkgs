{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  cargo,
  desktop-file-utils,
  gettext,
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

stdenv.mkDerivation (finalAttrs: {
  pname = "bustle";
  version = "0.13.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "bustle";
    tag = finalAttrs.version;
    hash = "sha256-+Pl4ze1nrC27NIfJ4FNc3iqYWBtCBpHp2zZNAxAPbJk=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    desktop-file-utils
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    glib
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Set the location to gettext to ensure the nixpkgs one on Darwin instead of the vendored one.
    # The vendored gettext does not build with clang 16.
    GETTEXT_BIN_DIR = "${lib.getBin buildPackages.gettext}/bin";
    GETTEXT_INCLUDE_DIR = "${lib.getDev gettext}/include";
    GETTEXT_LIB_DIR = "${lib.getLib gettext}/lib";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-el1zVFE8hsmIisHO+btvnA0WVN9bN8iuVPaSF02ovCI=";
  };

  meta = {
    description = "Graphical D-Bus message analyser and profiler";
    homepage = "https://gitlab.gnome.org/World/bustle";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      jtojnar
    ];

    platforms = lib.platforms.unix;
    mainProgram = "bustle";
    teams = [ lib.teams.gnome-circle ];
  };
})
