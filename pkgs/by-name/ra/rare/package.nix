{
  lib,
  fetchFromGitHub,
  legendary-gl,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rare";
  version = "1.10.11";

  src = fetchFromGitHub {
    owner = "RareDevs";
    repo = "Rare";
    tag = finalAttrs.version;
    hash = "sha256-2DtI5iaK4bYdGfIEhPy52WaEqh+IJMZ6qo/348lMnLY=";
  };

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    legendary-gl
  ];

  # Project has no tests
  doCheck = false;

  postInstall = ''
    install -Dm644 misc/rare.desktop -t $out/share/applications/
    install -Dm644 $out/${python3Packages.python.sitePackages}/rare/resources/images/Rare.png $out/share/icons/rare.png
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    orjson
    pypresence
    pyqt5
    qtawesome
    requests
    typing-extensions
  ];

  dontWrapQtApps = true;
  pyproject = true;

  meta = {
    description = "GUI for Legendary, an Epic Games Launcher open source alternative";
    homepage = "https://github.com/RareDevs/Rare";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "rare";
  };
})
