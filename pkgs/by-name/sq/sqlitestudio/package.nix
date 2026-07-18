{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  python3,
  qt5,
  readline,
  sqlitestudio-plugins,
  tcl,
  includeOfficialPlugins ? lib.meta.availableOn stdenv.hostPlatform sqlitestudio-plugins,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sqlitestudio";
  version = "3.4.21";

  src = fetchFromGitHub {
    owner = "pawelsalawa";
    repo = "sqlitestudio";
    rev = finalAttrs.version;
    hash = "sha256-xs0+bB0gPoDkIldaTA/nFofx9KPvIcyxe6kzcHuboxA=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt5.qmake
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    readline
    tcl
    python3
    qt5.qtbase
    qt5.qtsvg
    qt5.qtdeclarative
    qt5.qtscript
  ];

  postInstall = ''
    install -Dm755 \
      ./SQLiteStudio3/guiSQLiteStudio/img/sqlitestudio.svg \
      $out/share/pixmaps/sqlitestudio.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = "Database manager for SQLite";
      desktopName = "SQLiteStudio";
      exec = "sqlitestudio";
      icon = "sqlitestudio";
      name = "sqlitestudio";
      startupNotify = false;
      terminal = false;
    })
  ];

  enableParallelBuilding = true;

  qmakeFlags = [
    "./SQLiteStudio3"
    "DEFINES+=NO_AUTO_UPDATES"
  ]
  ++ lib.optionals includeOfficialPlugins [
    "DEFINES+=PLUGINS_DIR=${sqlitestudio-plugins}/lib/sqlitestudio"
  ];

  meta = {
    description = "Free, open source, multi-platform SQLite database manager";
    homepage = "https://sqlitestudio.pl/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ asterismono ];
    platforms = lib.platforms.linux;
    mainProgram = "sqlitestudio";
  };
})
