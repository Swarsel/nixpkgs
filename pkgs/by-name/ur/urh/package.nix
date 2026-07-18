{
  lib,
  stdenv,
  fetchFromGitHub,
  airspy,
  copyDesktopItems,
  hackrf,
  libbladeRF,
  libiio,
  limesuite,
  makeDesktopItem,
  python3Packages,
  qt5,
  rtl-sdr,
  uhd,
  wrapGAppsHook3,
  USRPSupport ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "urh";
  version = "2.9.8-unstable-2025-07-31";

  src = fetchFromGitHub {
    owner = "jopohl";
    repo = "urh";
    rev = "4979a5c94d7c0c728fa2ff3fda8f564e6ed6c7b4";
    hash = "sha256-oLtMyk9szXiHSPzEzhG58FQ2HAG4JTAPhJvk2rfycAc=";
  };

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    hackrf
    rtl-sdr
    airspy
    limesuite
    libiio
    libbladeRF
  ]
  ++ lib.optional USRPSupport uhd
  ++ lib.optional stdenv.hostPlatform.isLinux qt5.qtwayland;

  doCheck = false;

  postInstall = ''
    install -Dm644 data/icons/appicon.png $out/share/icons/hicolor/512x512/apps/urh.png
  '';

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      ''${qtWrapperArgs[@]}
    )
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    pyqt5
    numpy
    psutil
    cython
    pyzmq
    pyaudio
    setuptools
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "HamRadio"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Universal Radio Hacker";
      exec = "urh";
      icon = "urh";
      name = "urh";
    })
  ];

  # dont double wrap
  # https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-common-issues-double-wrapped
  dontWrapGApps = true;
  dontWrapQtApps = true;
  pyproject = true;

  meta = {
    description = "Universal Radio Hacker: investigate wireless protocols like a boss";
    homepage = "https://github.com/jopohl/urh";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
  };
})
