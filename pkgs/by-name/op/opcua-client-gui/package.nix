{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  desktopToDarwinBundle,
  makeDesktopItem,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "opcua-client-gui";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "FreeOpcUa";
    repo = "opcua-client-gui";
    tag = finalAttrs.version;
    hash = "sha256-0BH1Txr3z4a7iFcsfnovmBUreXMvIX2zpZa8QivQVx8=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt5.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    qt5.qtwayland
  ];

  propagatedBuildInputs = with python3Packages; [
    pyqt5
    asyncua
    opcua-widgets
    numpy
    pyqtgraph
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "OPC UA Client";
      #no icon because the app dosn't have one
      desktopName = "opcua-client";
      exec = "opcua-client";
      name = "opcua-client";
      terminal = false;
      type = "Application";
    })
  ];

  format = "setuptools";

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  meta = {
    description = "OPC UA GUI Client";
    homepage = "https://github.com/FreeOpcUa/opcua-client-gui";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "opcua-client";
  };
})
