{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cairo,
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
  openssl,
  pango,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "diebahn";
  version = "2.10.1";

  src = fetchFromGitLab {
    owner = "schmiddi-on-mobile";
    repo = "railway";
    tag = version;
    hash = "sha256-lmyseWTqOwMgKB3q+SQbpa4XNzZ+2hBe7Ct7o5oZjOc=";
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
    blueprint-compiler
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    openssl
    pango
  ];

  # Darwin needs to link against gettext from nixpkgs instead of the one vendored by gettext-sys
  # because the vendored copy does not build with newer versions of clang.
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    GETTEXT_BIN_DIR = "${lib.getBin gettext}/bin";
    GETTEXT_INCLUDE_DIR = "${lib.getDev gettext}/include";
    GETTEXT_LIB_DIR = "${lib.getLib gettext}/lib";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-ADJTkR0Lmr2mmhSvLhqryZYKLFjTHA+pGUbZPEBM7r4=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Travel with all your train information in one place. Also known as Railway";
    homepage = "https://gitlab.com/schmiddi-on-mobile/railway";
    changelog = "https://gitlab.com/schmiddi-on-mobile/railway/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      dotlambda
      lilacious
      cholli
    ];

    mainProgram = "diebahn";
    teams = [ lib.teams.gnome-circle ];
  };
}
