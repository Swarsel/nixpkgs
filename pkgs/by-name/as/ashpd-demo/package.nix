{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  cargo,
  common-updater-scripts,
  desktop-file-utils,
  gitUpdater,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  libshumate,
  meson,
  ninja,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  wayland,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ashpd-demo";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "bilelmoussaoui";
    repo = "ashpd";
    rev = "${finalAttrs.version}-demo";
    hash = "sha256-0IGqA8PM6I2p4/MrptkdSWIZThMoeaMsdMc6tVTI2MU=";
  };

  postPatch = ''
    cd ashpd-demo
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    rustPlatform.bindgenHook
    desktop-file-utils
    glib # for glib-compile-schemas
  ];

  buildInputs = [
    glib
    gtk4
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    libadwaita
    pipewire
    wayland
    libshumate
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = "${finalAttrs.src}/ashpd-demo";
    hash = "sha256-kUEzVBk8dKXCQdHFJJS633CBG1F57TIxJg1xApMwzbI=";
  };

  passthru = {
    updateScript =
      let
        updateSource = gitUpdater {
          rev-suffix = "-demo";
          url = finalAttrs.src.gitRepoUrl;
        };

        updateLockfile = {
          command = [
            "sh"
            "-c"
            ''
              PATH=${
                lib.makeBinPath [
                  common-updater-scripts
                ]
              }
              update-source-version ashpd-demo --ignore-same-version --source-key=cargoDeps.vendorStaging > /dev/null
            ''
          ];

          # Experimental feature: do not copy!
          supportedFeatures = [ "silent" ];
        };
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateLockfile
      ];
  };

  meta = {
    description = "Tool for playing with XDG desktop portals";
    homepage = "https://github.com/bilelmoussaoui/ashpd/tree/master/ashpd-demo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.linux;
    mainProgram = "ashpd-demo";
  };
})
