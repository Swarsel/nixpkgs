{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  python3Packages,
  qt6,
  replaceVars,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "openmotor";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "reilleya";
    repo = "openMotor";
    tag = "v${version}";
    hash = "sha256-5b/Q/qjd2EH+OG6pAZhPTnEnFy0e/reBH8sIH0DZORo=";
  };

  patches = [
    ./main-entrypoint.patch
    ./fix-setup.patch
  ];

  postPatch = ''
    # Substitute version placeholder in patched setup.py
    substituteInPlace setup.py --replace-fail '@version@' '${version}'
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.qtwayland
  ];

  preBuild = ''
    # Compile Qt Designer .ui files to Python modules
    find uilib/views/forms -name "*.ui" 2>/dev/null | while read ui_file; do
      py_file="uilib/views/$(basename "$ui_file" .ui)_ui.py"
      echo "Compiling $ui_file -> $py_file"
      pyuic6 "$ui_file" -o "$py_file"
    done

    # Ensure views directory has __init__.py
    touch uilib/views/__init__.py
  '';

  # Tests require additional setup and data files
  doCheck = false;

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # Install icons on Linux
    install -Dm644 resources/oMIconCycles.png $out/share/icons/hicolor/256x256/apps/openmotor.png
    install -Dm644 resources/oMIconCyclesSmall.png $out/share/icons/hicolor/128x128/apps/openmotor.png
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Create macOS app bundle
    mkdir -p $out/Applications/openMotor.app/Contents/{MacOS,Resources}

    # Install Info.plist
    install -Dm644 ${
      replaceVars ./Info.plist { inherit version; }
    } $out/Applications/openMotor.app/Contents/Info.plist

    # Use upstream's .icns icon
    install -Dm644 resources/oMIconCycles.icns $out/Applications/openMotor.app/Contents/Resources/openMotor.icns

    # Move the wrapped binary into the app bundle
    mv $out/bin/openMotor $out/Applications/openMotor.app/Contents/MacOS/

    # Create symlink back to bin for CLI access
    ln -s $out/Applications/openMotor.app/Contents/MacOS/openMotor $out/bin/openMotor
  '';

  build-system = with python3Packages; [
    setuptools
    cython
    pyqt6
  ];

  dependencies = with python3Packages; [
    cycler
    decorator
    ezdxf
    imageio
    matplotlib
    networkx
    numpy
    pillow
    platformdirs
    pyparsing
    pyqt6
    pyqt6-sip
    python-dateutil
    pyyaml
    scikit-fmm
    scikit-image
    scipy
    six
  ];

  desktopItems = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    (makeDesktopItem {
      categories = [
        "Science"
        "Engineering"
      ];

      comment = meta.description;
      desktopName = "openMotor";
      exec = "openMotor";
      icon = "openmotor";
      name = "openmotor";
    })
  ];

  pyproject = true;

  pythonImportsCheck = [
    "motorlib"
    "uilib"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source internal ballistics simulator for rocket motor experimenters";

    longDescription = ''
      openMotor is an open-source internal ballistics simulator for rocket motor
      experimenters. The software estimates a rocket motor's chamber pressure and
      thrust based on propellant properties, grain geometry, and nozzle specifications.
      It uses the Fast Marching Method to determine how a propellant grain regresses,
      which allows the use of arbitrary core geometries.
    '';

    homepage = "https://github.com/reilleya/openMotor";
    changelog = "https://github.com/reilleya/openMotor/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ schembriaiden ];
    platforms = lib.platforms.unix;
    mainProgram = "openMotor";
  };
}
