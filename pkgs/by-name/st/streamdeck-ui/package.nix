{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  python3Packages,
  qt6,
  udevCheckHook,
  wrapGAppsHook3,
  writeText,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "streamdeck-ui";
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "streamdeck-linux-gui";
    repo = "streamdeck-linux-gui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XRtIkDyLick9Pq55Br7lQb6FoygMs4DZEJoAD2/o+pQ=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
    wrapGAppsHook3
    udevCheckHook
  ];

  propagatedBuildInputs =
    with python3Packages;
    [
      setuptools
      filetype
      cairosvg
      pillow
      pynput
      pyside6
      streamdeck
      python-xlib
      importlib-metadata
      evdev
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ qt6.qtwayland ];

  nativeCheckInputs = [
    xvfb-run
  ]
  ++ (with python3Packages; [
    pytest
    pytest-qt
    pytest-mock
  ]);

  checkPhase = ''
    runHook preCheck

    # The tests needs to find the log file
    export STREAMDECK_UI_LOG_FILE=$(pwd)/.streamdeck_ui.log
    xvfb-run pytest tests

    runHook postCheck
  '';

  postInstall =
    let
      udevRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
      '';
    in
    ''
      mkdir -p $out/lib/systemd/user
      substitute scripts/streamdeck.service $out/lib/systemd/user/streamdeck.service \
        --replace '<path to streamdeck>' $out/bin/streamdeck

      mkdir -p "$out/etc/udev/rules.d"
      cp ${writeText "70-streamdeck.rules" udevRules} $out/etc/udev/rules.d/70-streamdeck.rules

      mkdir -p "$out/share/pixmaps"
      cp streamdeck_ui/logo.png $out/share/pixmaps/streamdeck-ui.png
    '';

  build-system = [
    python3Packages.poetry-core
  ];

  desktopItems =
    let
      common = {
        categories = [ "Utility" ];
        comment = "UI for the Elgato Stream Deck";
        desktopName = "Stream Deck UI";
        exec = "streamdeck";
        icon = "streamdeck-ui";
        name = "streamdeck-ui";
      };
    in
    map makeDesktopItem [
      common
      (
        common
        // {
          exec = "${common.exec} --no-ui";
          name = "${common.name}-noui";
          noDisplay = true;
        }
      )
    ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "importlib-metadata"
    "pillow"
  ];

  meta = {
    description = "Linux compatible UI for the Elgato Stream Deck";
    homepage = "https://streamdeck-linux-gui.github.io/streamdeck-linux-gui/";
    changelog = "https://github.com/streamdeck-linux-gui/streamdeck-linux-gui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ majiir ];
    mainProgram = "streamdeck";
    downloadPage = "https://github.com/streamdeck-linux-gui/streamdeck-linux-gui/";
  };
})
