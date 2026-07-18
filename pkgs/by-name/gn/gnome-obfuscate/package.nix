{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  buildPackages,
  cargo,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
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
  pname = "gnome-obfuscate";
  version = "0.0.10";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Obfuscate";
    rev = finalAttrs.version;
    hash = "sha256-/Plvvn1tle8t/bsPcsamn5d81CqnyGCyGYPF6j6U5NI=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    gdk-pixbuf
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
    hash = "sha256-Llgn+dYNKZ9Mles9f9Xor+GZoCCQ0cERkXz4MicZglY=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Censor private information";
    homepage = "https://gitlab.gnome.org/World/obfuscate";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "obfuscate";
    teams = [ lib.teams.gnome-circle ];
  };
})
