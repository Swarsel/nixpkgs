{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  onedrive,
  python3Packages,
  qt6,
  writeText,
}:

let
  version = "1.3.2";

  setupPy = writeText "setup.py" ''
    from setuptools import setup
    setup(
      name='onedrivegui',
      version='${version}',
      scripts=[
        'src/OneDriveGUI.py',
      ],
    )
  '';

in
python3Packages.buildPythonApplication rec {
  inherit version;
  pname = "onedrivegui";

  src = fetchFromGitHub {
    owner = "bpozdena";
    repo = "OneDriveGUI";
    tag = "v${version}";
    hash = "sha256-KgpQShjSjZHNBC/aovpl/VQO5zhJZ8+8GLup75m0gJo=";
  };

  postPatch = ''
    # Patch global_config.py so DIR_PATH points to shared files location
    sed -i src/global_config.py -e "s@^DIR_PATH =.*@DIR_PATH = '$out/share/OneDriveGUI'@"
    cp ${setupPy} ${setupPy.name}
  '';

  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  doCheck = false; # No tests defined

  postInstall = ''
    mkdir -p $out/share/OneDriveGUI
    # we do not need the `ui` directory - only resources
    cp -r src/resources $out/share/OneDriveGUI
    install -Dm444 -t $/out/share/icons/hicolor/48x48/apps src/resources/images/OneDriveGUI.png
    # we put our own executable wrapper in place instead
    rm -r $out/bin/*

    makeWrapper ${python3Packages.python.interpreter} $out/bin/onedrivegui \
      ''${qtWrapperArgs[@]} \
      --prefix PATH : ${lib.makeBinPath [ onedrive ]} \
      --prefix PYTHONPATH : ${
        python3Packages.makePythonPath (dependencies ++ [ (placeholder "out") ])
      } \
      --add-flags $out/${python3Packages.python.sitePackages}/OneDriveGUI.py
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyside6
    requests
  ];

  # pythonImportsCheck = [ "OneDriveGUI" ]; # requires a display
  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "OneDrive GUI Client";
      desktopName = "OneDriveGUI";
      exec = "onedrivegui";
      icon = "OneDriveGUI";
      name = "OneDriveGUI";
      terminal = false;
      type = "Application";
    })
  ];

  # wrap manually to avoid having a bash script in $out/bin with a .py extension
  dontWrapPythonPrograms = true;
  dontWrapQtApps = true;
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple GUI for Linux OneDrive Client, with multi-account support";
    homepage = "https://github.com/bpozdena/OneDriveGUI";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ philipdb ];
    platforms = lib.platforms.linux;
    mainProgram = "onedrivegui";
  };
}
