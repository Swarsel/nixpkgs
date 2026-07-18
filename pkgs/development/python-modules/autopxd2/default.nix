{
  lib,
  buildPythonPackage,
  click,
  cython,
  fetchPypi,
  pycparser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-autopxd2";
  version = "3.2.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-fzq5xy7vPjxwgaEyBXk3Ke9JnySJ3PM5WAucFCZ/IP8=";
    pname = "autopxd2";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pycparser
    click
    cython
  ];

  enabledTestPaths = [
    "test/"
  ];

  pyproject = true;

  meta = {
    description = "Generates .pxd files automatically from .h files";
    homepage = "https://github.com/elijahr/python-autopxd2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    mainProgram = "autopxd";
  };
}
