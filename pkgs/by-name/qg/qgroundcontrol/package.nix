{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  gst_all_1,
  libsForQt5,
  nix-update-script,
  pkg-config,
  wayland,
}:

stdenv.mkDerivation rec {
  pname = "qgroundcontrol";
  version = "4.4.5";

  # TODO: package mavlink so we can build from a normal source tarball
  src = fetchFromGitHub {
    owner = "mavlink";
    repo = "qgroundcontrol";
    tag = "v${version}";
    hash = "sha256-wjrfwE97J+UzBPIARQ6cPadN6xIdqR8i+ZKbtiDproM=";
    fetchSubmodules = true;
  };

  patches = [
    ./disable-bad-message.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ]
  ++ (with libsForQt5; [
    qmake
    qttools
    wrapQtAppsHook
  ]);

  buildInputs = [ SDL2 ] ++ gstInputs ++ propagatedBuildInputs;

  propagatedBuildInputs = with libsForQt5; [
    qtbase
    qtcharts
    qtlocation
    qtserialport
    qtsvg
    qtquickcontrols2
    qtgraphicaleffects
    qtspeech
    qtx11extras
  ];

  preConfigure = ''
    mkdir build
    cd build
  '';

  installPhase = ''
    runHook preInstall

    cd ..

    mkdir -p $out/share/applications
    sed 's/Exec=.*$/Exec=QGroundControl/g' --in-place deploy/qgroundcontrol.desktop
    cp -v deploy/qgroundcontrol.desktop $out/share/applications

    mkdir -p $out/bin
    cp -v build/staging/QGroundControl "$out/bin/"

    mkdir -p $out/share/qgroundcontrol
    cp -rv resources/ $out/share/qgroundcontrol

    install -D resources/icons/qgroundcontrol.png -t $out/share/icons/hicolor/128x128/apps

    runHook postInstall
  '';

  postInstall = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  gstInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    (gst-plugins-good.override { qt5Support = true; })
    gst-plugins-bad
    gst-libav
    wayland
  ];

  qmakeFlags = [
    "CONFIG+=StableBuild"
    # Default install tries to copy Qt files into package
    "CONFIG+=QGC_DISABLE_BUILD_SETUP"
    # Tries to download x86_64-only prebuilt binaries
    "DEFINES+=DISABLE_AIRMAP"
    "../qgroundcontrol.pro"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Provides full ground station support and configuration for the PX4 and APM Flight Stacks";
    homepage = "https://qgroundcontrol.com/";
    changelog = "https://github.com/mavlink/qgroundcontrol/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      lopsided98
      pandapip1
    ];

    platforms = lib.platforms.linux;
    mainProgram = "QGroundControl";
  };
}
