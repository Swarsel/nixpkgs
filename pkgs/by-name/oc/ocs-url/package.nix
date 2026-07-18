{
  lib,
  stdenv,
  fetchgit,
  qt5,
}:

let
  version = "3.1.0";

  main_src = fetchgit {
    rev = "release-${version}";
    sha256 = "RvbkcSj8iUAHAEOyETwfH+3XnCCY/p8XM8LgVrZxrws=";
    url = "https://www.opencode.net/dfn2/ocs-url.git";
  };

  qtil_src = fetchgit {
    rev = "v0.4.0";
    sha256 = "XRSp0F7ggfkof1RNAnQU3+O9DcXDy81VR7NakITOXrw=";
    url = "https://github.com/akiraohgaki/qtil";
  };
in

stdenv.mkDerivation {
  inherit version;
  pname = "ocs-url";

  buildInputs = [
    qt5.qtbase
    qt5.qtsvg
    qt5.qtquickcontrols
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  # We are NOT in $sourceRoot here
  postUnpack = ''
    mkdir -p $sourceRoot/lib/qtil
    cp -r ${qtil_src.name}/* $sourceRoot/lib/qtil/
  '';

  sourceRoot = main_src.name;

  srcs = [
    main_src
    qtil_src
  ];

  meta = {
    description = "Open Collaboration System for use with DE store websites";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ SohamG ];
    platforms = lib.platforms.linux;
    mainProgram = "ocs-url";
  };
}
