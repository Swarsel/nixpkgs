{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  cargo,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icon-library";
  version = "0.0.19";

  src = fetchurl {
    url = "https://gitlab.gnome.org/World/design/icon-library/uploads/7725604ce39be278abe7c47288085919/icon-library-${finalAttrs.version}.tar.xz";
    hash = "sha256-nWGTYoSa0/fxnD0Mb2132LkeB1oa/gj/oIXBbI+FDw8=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Set the location to gettext to ensure the nixpkgs one on Darwin instead of the vendored one.
    # The vendored gettext does not build with clang 16.
    GETTEXT_BIN_DIR = "${lib.getBin buildPackages.gettext}/bin";
    GETTEXT_INCLUDE_DIR = "${lib.getDev gettext}/include";
    GETTEXT_LIB_DIR = "${lib.getLib gettext}/lib";
  };

  meta = {
    description = "Symbolic icons for your apps";
    homepage = "https://gitlab.gnome.org/World/design/icon-library";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.unix;
    mainProgram = "icon-library";
  };
})
