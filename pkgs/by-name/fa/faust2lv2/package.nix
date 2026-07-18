{
  bash,
  boost,
  faust,
  lv2,
  qt5,
}:

faust.wrapWithBuildEnv {

  buildInputs = [
    bash
  ];

  propagatedBuildInputs = [
    boost
    lv2
    qt5.qtbase
  ];

  preFixup = ''
    sed -i "/QMAKE=/c\ QMAKE="${qt5.qtbase.dev}/bin/qmake"" "$out"/bin/faust2lv2;
  '';

  baseName = "faust2lv2";
  dontWrapQtApps = true;
}
