{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  cargo,
  desktop-file-utils,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  wayland,
  wrapGAppsHook4,
  zbar,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "authenticator";
  version = "4.6.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Authenticator";
    tag = finalAttrs.version;
    hash = "sha256-UvHIVUed4rxmjliaZ7jnwCjiHyvUDihoJyG3G+fYtow=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-bad.override { enableZbar = true; })
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-rs
    gtk4
    libadwaita
    openssl
    pipewire
    sqlite
    wayland
    zbar
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # vp8enc preset
      --prefix GST_PRESET_PATH : "${gst_all_1.gst-plugins-good}/share/gstreamer-1.0/presets"
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-iOIGm3egVtVM6Eb3W5/ys9nQV5so0dnv2ZODjQwrVyw=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Two-factor authentication code generator for GNOME";
    homepage = "https://gitlab.gnome.org/World/Authenticator";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ austinbutler ];
    platforms = lib.platforms.linux;
    mainProgram = "authenticator";
    teams = [ lib.teams.gnome-circle ];
  };
})
