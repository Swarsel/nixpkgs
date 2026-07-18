{
  lib,
  stdenv,
  fetchFromGitLab,
  bluez,
  cmake,
  connman,
  ffmpeg,
  gawk,
  grim,
  iio-sensor-proxy,
  inotify-tools,
  libcprime,
  libcsys,
  libdbusmenu,
  libnotify,
  libxdamage,
  networkmanager,
  ninja,
  playerctl,
  polkit,
  qt6,
  redshift,
  systemd,
  v4l-utils,
  wf-recorder,
  xdg-utils,
  xinput,
  xrandr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coretoppings";
  version = "5.0.0";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "coretoppings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wHVdZqXn8DXqLbCdKz2fI8BjNVai5dRq3a45HVCvLa8=";
  };

  patches = [
    # Fix file cannot create directory: /var/empty/share/polkit-1/actions
    ./0001-fix-install-phase.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtconnectivity
    libdbusmenu
    ffmpeg
    v4l-utils
    grim
    wf-recorder
    playerctl
    xrandr
    xinput
    libxdamage
    iio-sensor-proxy
    inotify-tools
    bluez
    networkmanager
    connman
    redshift
    gawk
    polkit
    libnotify
    systemd
    xdg-utils
    libcprime
    libcsys
  ];

  meta = {
    description = "Additional features,plugins etc for CuboCore Application Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/coretoppings";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "shareIT";
  };
})
