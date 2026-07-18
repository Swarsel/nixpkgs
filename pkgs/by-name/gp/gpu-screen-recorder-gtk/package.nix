{
  lib,
  stdenv,
  addDriverRunpath,
  desktop-file-utils,
  fetchgit,
  gitUpdater,
  gpu-screen-recorder,
  gtk3,
  libayatana-appindicator,
  libdrm,
  libglvnd,
  libpulseaudio,
  libx11,
  libxrandr,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  wayland,
  wrapGAppsHook3,
  wrapperDir ? "/run/wrappers/bin",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-screen-recorder-gtk";
  version = "5.7.9";

  src = fetchgit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-gtk";
    tag = finalAttrs.version;
    hash = "sha256-RFY5hQqv5XkLliB3+YJX4TXLxV9y1/P8PIYMi6MCbww=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    pkg-config
    makeWrapper
    meson
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    libpulseaudio
    libdrm
    libx11
    libxrandr
    wayland
  ];

  preFixup =
    let
      gpu-screen-recorder-wrapped = gpu-screen-recorder.override {
        inherit wrapperDir;
      };
    in
    ''
      gappsWrapperArgs+=(--prefix PATH : ${wrapperDir})
      gappsWrapperArgs+=(--suffix PATH : ${lib.makeBinPath [ gpu-screen-recorder-wrapped ]})
      gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libglvnd
          addDriverRunpath.driverLink
        ]
      })
    '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "GTK frontend for gpu-screen-recorder";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-gtk/about/";
    changelog = "https://git.dec05eba.com/gpu-screen-recorder-gtk/tree/com.dec05eba.gpu_screen_recorder.appdata.xml#n82";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      babbaj
      js6pak
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gpu-screen-recorder-gtk";
  };
})
