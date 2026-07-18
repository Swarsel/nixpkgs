{
  lcms2,
  libcanberra,
  libdisplay-info,
  libgbm,
  libxcvt,
  mkKdeDerivation,
  pkg-config,
  python3,
  qt5compat,
  qtsensors,
  qttools,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kwin-x11";

  patches = [
    ./0001-NixOS-Unwrap-executable-name-for-.desktop-search.patch
  ];

  postPatch = ''
    patchShebangs src/plugins/strip-effect-metadata.py
  '';

  # plugin QML relies on non-global imports
  dontQmlLint = true;

  extraBuildInputs = [
    qt5compat
    qtsensors
    qttools
    qtwayland

    libgbm
    lcms2
    libcanberra
    libdisplay-info

    libxcvt
  ];

  extraNativeBuildInputs = [
    pkg-config
    python3
  ];
}
