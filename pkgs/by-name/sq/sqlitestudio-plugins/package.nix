{
  lib,
  stdenv,
  python3,
  sqlitestudio,
}:
stdenv.mkDerivation {
  inherit (sqlitestudio)
    version
    src
    nativeBuildInputs
    buildInputs
    ;

  pname = "sqlitestudio-plugins";

  postConfigure = ''
    uic ./SQLiteStudio3/guiSQLiteStudio/mainwindow.ui -o ./SQLiteStudio3/guiSQLiteStudio/ui_mainwindow.h
  '';

  # bin/ld: final link failed: bad value
  enableParallelBuilding = false;

  qmakeFlags = [
    "./Plugins"
    "PYTHON_VERSION=${python3.pythonVersion}"
    "INCLUDEPATH+=${python3}/include/python${python3.pythonVersion}"
  ];

  meta = sqlitestudio.meta // {
    description = "Official plugins for SQLiteStudio, a free, open source, multi-platform SQLite database manager";
    badPlatforms = [ lib.systems.inspect.platformPatterns.isStatic ];
  };
}
