{
  lib,
  stdenv,
  fetchFromCodeberg,
  pkg-config,
  qt6,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ubpm";
  version = "1.13.0-unstable-2025-10-18";

  src = fetchFromCodeberg {
    owner = "LazyT";
    repo = "ubpm";
    rev = "748ce8504185ae96dbdbd1cff5352d1eef2c046d";
    hash = "sha256-WSweHj4+qgjqEsn0TNtmbVXjFJD84EWkdqK44/CsqgQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.qttools
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialport
    qt6.qtconnectivity
    qt6.qtcharts
    qt6.qtsvg
    udev
  ];

  postFixup = ''
    wrapQtApp $out/bin/ubpm
  '';

  baseVersion = lib.head (lib.splitString "-" finalAttrs.version);
  # *.so plugins are being wrapped automatically which breaks them
  dontWrapQtApps = true;

  qmakeFlags = [
    "DEFINES+=DISTRIBUTION"
    "DEFINES+=UPDATE_HIDE"
    "DEFINES+=UPDATE_DISABLE"
  ];

  sourceRoot = "${finalAttrs.src.name}/sources";

  meta = {
    description = "Universal Blood Pressure Manager";
    homepage = "https://codeberg.org/LazyT/ubpm";
    changelog = "https://codeberg.org/LazyT/ubpm/releases/tag/${finalAttrs.baseVersion}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kurnevsky ];
    mainProgram = "ubpm";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
