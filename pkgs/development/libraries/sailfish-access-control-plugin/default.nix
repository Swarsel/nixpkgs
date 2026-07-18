{
  lib,
  stdenv,
  pkg-config,
  qmake,
  qtbase,
  qtdeclarative,
  sailfish-access-control,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (sailfish-access-control) version src patches;
  pname = "sailfish-access-control-plugin";

  postPatch = ''
    substituteInPlace qt/qt.pro \
      --replace-fail '$$[QT_INSTALL_QML]' '${placeholder "out"}/${qtbase.qtQmlPrefix}'
  '';

  # QMake doesn't handle strictDeps well
  strictDeps = false;

  nativeBuildInputs = [
    pkg-config
    qmake
    qtdeclarative # qmlplugindump
  ];

  buildInputs = [
    qtdeclarative
    sailfish-access-control
  ];

  # sourceRoot breaks patches
  preConfigure = ''
    cd qt
  '';

  # Do all configuring now, not during build
  postConfigure = ''
    make qmake_all
  '';

  # Qt plugin
  dontWrapQtApps = true;

  meta = {
    inherit (sailfish-access-control.meta)
      homepage
      changelog
      license
      teams
      platforms
      ;

    description = "QML interface for sailfish-access-control";
  };
})
