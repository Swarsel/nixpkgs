{
  lib,
  # tests
  astropy,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pillow,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyavm";
  version = "0.9.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zhHCeex1vfgj0MOGEkoVKKXns2+l3U0mSZInk58Rf4g=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    astropy
    numpy
    pillow
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyavm" ];

  meta = {
    description = "Simple pure-python AVM meta-data handling";
    homepage = "https://astrofrog.github.io/pyavm/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ smaret ];
  };
}
