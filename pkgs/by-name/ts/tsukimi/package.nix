{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  cargo,
  dbus,
  desktop-file-utils,
  ffmpeg,
  gst_all_1,
  libadwaita,
  libepoxy,
  libxml2,
  meson,
  mpv-unwrapped,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  versionCheckHook,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tsukimi";
  version = "26.7.1";

  src = fetchFromGitHub {
    owner = "tsukinaha";
    repo = "tsukimi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PGd2dWmUfdOyBsfn2Jozb7tAxSy2sv8XOKL1K8FwuLE=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustc
    cargo
    desktop-file-utils
    libxml2 # xmllint
    appstream # appstreamcli
  ];

  buildInputs = [
    mpv-unwrapped
    ffmpeg
    libadwaita
    openssl
    libepoxy
    dbus
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  mesonFlags = [
    "-Drust-target=release"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-lfDPrmCl+Fuf/AG8xiFv00HD76Wy63cBc9Iji7Cw2sw=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple third-party Emby client, featured with GTK4-RS, MPV and GStreamer";
    homepage = "https://github.com/tsukinaha/tsukimi";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      merrkry
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "tsukimi";
  };
})
