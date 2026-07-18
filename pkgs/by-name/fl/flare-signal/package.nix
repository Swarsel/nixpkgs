{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  gst_all_1,
  gtksourceview5,
  libadwaita,
  libsecret,
  libspelling,
  meson,
  ninja,
  openssl,
  perl,
  pkg-config,
  protobuf,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flare";
  version = "0.21.0";

  src = fetchFromGitLab {
    owner = "schmiddi-on-mobile";
    repo = "flare";
    tag = finalAttrs.version;
    hash = "sha256-Vt83VsqylFSM2rUj5egu1FEFjaVLVUI8SeGHAXmgKW4=";
  };

  nativeBuildInputs = [
    appstream # for appstream-util
    blueprint-compiler
    desktop-file-utils # for update-desktop-database
    meson
    ninja
    perl
    pkg-config
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    gtksourceview5
    libadwaita
    libsecret
    libspelling
    openssl
    protobuf

    # To reproduce audio messages
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-GlkrQtMGFqujEiwAVMts6nsPbQ2GTxwYIJsu6axeg0Q=";
  };

  meta = {
    description = "Unofficial Signal GTK client";
    homepage = "https://gitlab.com/schmiddi-on-mobile/flare";
    changelog = "https://gitlab.com/schmiddi-on-mobile/flare/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "flare";
  };
})
