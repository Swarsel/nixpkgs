{
  lib,
  stdenv,
  fetchurl,
  cargo,
  desktop-file-utils,
  glib,
  glycin-loaders,
  gnome,
  gst_all_1,
  gtk4,
  lcms2,
  libadwaita,
  libcamera,
  libglycin,
  libglycin-gtk4,
  libseccomp,
  meson,
  ninja,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapshot";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/snapshot/${lib.versions.major finalAttrs.version}/snapshot-${finalAttrs.version}.tar.xz";
    hash = "sha256-7J2vmIPrkDMJEbtR5rae7YydvdVDjoZK3JDuVaX+nu0=";
  };

  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "'cp', cargo_target / rust_target / meson.project_name()" \
      "'cp', cargo_target / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name()"
  '';

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    libglycin
    libglycin.setupHook
    libglycin-gtk4
    glycin-loaders
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-rs # for gtk4paintablesink
    gst_all_1.gstreamer
    gtk4
    libadwaita
    libcamera # for the gstreamer plugin
    lcms2
    libseccomp
    pipewire # for device provider
  ];

  # For https://gitlab.gnome.org/GNOME/snapshot/-/blob/34236a6dded23b66fdc4e4ed613e5b09eec3872c/src/meson.build#L57
  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  preFixup = ''
    gappsWrapperArgs+=(
      # vp8enc preset
      --prefix GST_PRESET_PATH : "${gst_all_1.gst-plugins-good}/share/gstreamer-1.0/presets"
    )
  '';

  cargoVendorDir = "vendor";

  passthru.updateScript = gnome.updateScript {
    packageName = "snapshot";
  };

  meta = {
    description = "Take pictures and videos on your computer, tablet, or phone";
    homepage = "https://gitlab.gnome.org/GNOME/snapshot";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "snapshot";
    teams = [ lib.teams.gnome ];
  };
})
