{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "flashgbx";
  version = "4.4";

  src = fetchFromGitHub {
    owner = "lesserkuma";
    repo = "FlashGBX";
    tag = finalAttrs.version;
    hash = "sha256-C5RljQB6km5yYvFRj/s5AZfMIuMmaqsHnn9BhYWAP4o=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];

  propagatedBuildInputs =
    with python3Packages;
    [
      pillow
      pyserial
      pyside6
      python-dateutil
      requests
      setuptools
      qt6.qtbase
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      qt6.qtwayland
    ];

  postInstall = ''
    install -D FlashGBX/res/icon.png $out/share/icons/hicolor/256x256/apps/flashgbx.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "UI for reading and writing Game Boy and Game Boy Advance cartridges";
      desktopName = "FlashGBX UI";
      exec = finalAttrs.meta.mainProgram;
      icon = "flashgbx";
      name = "flashgbx";
    })
  ];

  pyproject = true;

  meta = {
    description = "GUI for reading and writing GB and GBA cartridges with the GBxCart RW";
    homepage = "https://github.com/lesserkuma/FlashGBX";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ grahamnorris ];
    mainProgram = "flashgbx";
  };
})
