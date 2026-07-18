{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hyperframe";
  version = "6.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9jCQigCFSnreq9Y4K0OSOkxM1Lgh/LUn5queFTgqOwg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hyperframe" ];

  meta = {
    description = "HTTP/2 framing layer for Python";
    homepage = "https://github.com/python-hyper/hyperframe/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
