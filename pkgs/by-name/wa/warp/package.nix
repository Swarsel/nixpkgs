{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  cargo,
  desktop-file-utils,
  glib,
  gst_all_1,
  gtk4,
  itstool,
  libadwaita,
  libcamera,
  meson,
  ninja,
  nix-update-script,
  pipewire,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "warp";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "warp";
    tag = "v${version}";
    hash = "sha256-cFMIMNAVrP3rF7UQeKgSdaRZmJT8XcERR4BSLYqxSoI=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libcamera
    pipewire
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-bad
    gst-plugins-good # multifilesink
    gst-plugins-rs # gst-plugin-gtk4
  ]);

  preFixup = ''
    gappsWrapperArgs+=(
      # vp8enc preset
      --prefix GST_PRESET_PATH : ${gst_all_1.gst-plugins-good}/share/gstreamer-1.0/presets
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-CFe6Hg1cSz59agZ/eCL7PfnMe/N0vJvAs3gzfjZCwlY=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast and secure file transfer";
    homepage = "https://apps.gnome.org/Warp/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      dotlambda
    ];

    platforms = lib.platforms.all;
    mainProgram = "warp";
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.gnome-circle ];
  };
}
