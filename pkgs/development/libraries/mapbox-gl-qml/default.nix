{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  maplibre-native-qt,
  qtbase,
  qtpositioning,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mapbox-gl-qml";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "rinigus";
    repo = "mapbox-gl-qml";
    tag = finalAttrs.version;
    hash = "sha256-csk3Uo+AdP1R/T/9gWyWmYFIKuen2jy8wYN3GJznyRE=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    maplibre-native-qt
    qtpositioning
  ];

  cmakeFlags = [
    (lib.cmakeFeature "QT_INSTALL_QML" "${placeholder "out"}/${qtbase.qtQmlPrefix}")
  ];

  dontWrapQtApps = true; # library only

  meta = {
    description = "Unofficial Mapbox GL Native bindings for Qt QML";
    homepage = "https://github.com/rinigus/mapbox-gl-qml";
    changelog = "https://github.com/rinigus/mapbox-gl-qml/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      Thra11
      dotlambda
    ];

    platforms = lib.platforms.linux;
  };
})
