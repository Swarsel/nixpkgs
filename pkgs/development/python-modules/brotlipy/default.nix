{
  lib,
  buildPythonPackage,
  cffi,
  construct,
  fetchPypi,
  hypothesis,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "brotlipy";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Nt7wuFm+ryGRAVe0wz6zsG2M5FnJQhAvFpiMym6hZN8=";
  };

  # Missing test files
  doCheck = false;

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cffi
    construct
  ];

  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "brotli" ];

  meta = {
    description = "Python bindings for the reference Brotli encoder/decoder";
    homepage = "https://github.com/python-hyper/brotlipy/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
