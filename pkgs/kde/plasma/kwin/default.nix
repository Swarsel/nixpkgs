{
  krunner,
  lcms2,
  libcanberra,
  libdisplay-info,
  libei,
  libevdev,
  libgbm,
  libinput,
  libxcvt,
  mkKdeDerivation,
  pipewire,
  pkg-config,
  python3,
  qtquick3d,
  qtsensors,
  qttools,
  qtvirtualkeyboard,
  qtwayland,
  xwayland,
}:
mkKdeDerivation {
  pname = "kwin";

  patches = [
    ./0003-plugins-qpa-allow-using-nixos-wrapper.patch
    ./0001-NixOS-Unwrap-executable-name-for-.desktop-search.patch
  ];

  postPatch = ''
    patchShebangs src/plugins/strip-effect-metadata.py
  '';

  # plugin QML relies on non-global imports
  dontQmlLint = true;

  extraBuildInputs = [
    qtquick3d
    qtsensors
    qttools
    qtvirtualkeyboard
    qtwayland

    krunner

    libgbm
    lcms2
    libcanberra
    libdisplay-info
    libei
    libevdev
    libinput
    pipewire

    libxcvt
    # we need to provide this so it knows our xwayland supports new features
    xwayland
  ];

  extraNativeBuildInputs = [
    pkg-config
    python3
  ];

  # TZDIR may be unset when running through the kwin_wayland wrapper,
  # but we need it for the lockscreen clock to render
  qtWrapperArgs = [
    "--set-default TZDIR /etc/zoneinfo"
  ];
}
