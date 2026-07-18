{
  lib,
  buildPythonPackage,
  cxxfilt,
  fetchPypi,
  msgpack,
  pyasn1,
  pyasn1-modules,
  pycparser,
  pyqt5,
  setuptools,
  wrapQtAppsHook,
  # pyqtwebengine, # removed
  withGui ? false,
}:

buildPythonPackage rec {
  pname = "vivisect";
  version = "1.3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UQryZ4aGVEr5vRLElmTwRNtgi3h6CPzzq5n+E58tuo8=";
  };

  nativeBuildInputs = lib.optionals withGui [
    wrapQtAppsHook
  ];

  # Tests requires another repo for test files
  doCheck = false;

  postFixup = lib.optionalString withGui ''
    wrapQtApp $out/bin/vivbin
  '';

  build-system = [ setuptools ];

  dependencies = [
    pyasn1
    pyasn1-modules
    cxxfilt
    msgpack
    pycparser
  ]
  ++ lib.optionals withGui optional-dependencies.gui;

  optional-dependencies.gui = [
    pyqt5
    # pyqtwebengine
  ];

  pyproject = true;
  pythonImportsCheck = [ "vivisect" ];

  pythonRelaxDeps = [
    "cxxfilt"
    "msgpack"
    "pyasn1"
    "pyasn1-modules"
  ];

  meta = {
    description = "Python disassembler, debugger, emulator, and static analysis framework";
    homepage = "https://github.com/vivisect/vivisect";
    changelog = "https://github.com/vivisect/vivisect/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
    broken = withGui; # https://github.com/vivisect/vivisect/issues/683
  };
}
