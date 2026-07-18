{
  lib,
  fetchFromGitHub,
  jre,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "eddy";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "obdasystems";
    repo = "eddy";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-K8yd7A4D1LAgwuaJvxdF0oqACuMxX/CZ6yKbR7D+uEQ=";
  };

  propagatedBuildInputs = [
    qt5.qtbase
    qt5.wrapQtAppsHook
    python3Packages.setuptools
    python3Packages.rfc3987
    python3Packages.jpype1
    python3Packages.pyqt5
  ];

  preBuild = ''
    export HOME=/tmp
  '';

  # Tests fail with: ImportError: cannot import name 'QtXmlPatterns' from 'PyQt5'
  doCheck = false;

  preFixup = ''
    wrapQtApp "$out/bin/eddy" --prefix JAVA_HOME : ${jre}
  '';

  format = "setuptools";

  meta = {
    description = "Graphical editor for the specification and visualization of Graphol ontologies";
    homepage = "http://www.obdasystems.com/eddy";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ koslambrou ];
    platforms = lib.platforms.linux;
    mainProgram = "eddy";
  };
})
