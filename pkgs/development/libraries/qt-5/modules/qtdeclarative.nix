{
  python3,
  qtModule,
  qtbase,
  qtsvg,
}:

qtModule {
  pname = "qtdeclarative";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  nativeBuildInputs = [ python3 ];

  propagatedBuildInputs = [
    qtbase
    qtsvg
  ];

  configureFlags = [ "-qml-debug" ];

  preConfigure = ''
    NIX_CFLAGS_COMPILE+=" -DNIXPKGS_QML2_IMPORT_PREFIX=\"$qtQmlPrefix\""
  '';

  devTools = [
    "bin/qml"
    "bin/qmlcachegen"
    "bin/qmleasing"
    "bin/qmlimportscanner"
    "bin/qmllint"
    "bin/qmlmin"
    "bin/qmlplugindump"
    "bin/qmlprofiler"
    "bin/qmlscene"
    "bin/qmltestrunner"
  ];
}
