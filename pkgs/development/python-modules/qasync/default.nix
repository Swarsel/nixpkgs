{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyqt6,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "qasync";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "CabbageDevelopment";
    repo = "qasync";
    tag = "v${version}";
    hash = "sha256-eQJ1Yszl95IycggSyWcD3opAO1rfBdNp14y8eHDMJY4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.3,<0.9.0" uv_build
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pyqt6
  ];

  build-system = [ uv-build ];

  # crashes the interpreter
  disabledTestPaths = [
    "tests/test_qeventloop.py"
    "tests/test_run.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "qasync" ];

  meta = {
    description = "Allows coroutines to be used in PyQt/PySide applications by providing an implementation of the PEP 3156 event-loop";
    homepage = "https://github.com/CabbageDevelopment/qasync";
    license = [ lib.licenses.bsd2 ];
    maintainers = [ ];
  };
}
