{
  lib,
  astropy,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  pillow,
  pyavm,
  pyregion,
  pytest-astropy,
  pytestCheckHook,
  reproject,
  scikit-image,
  setuptools,
  setuptools-scm,
  shapely,
}:

buildPythonPackage rec {
  pname = "aplpy";
  version = "2.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-P7PVueaMYXgVwXW+ema2ofP9QiBtaN/gQXZq0yIFJhA=";
    pname = "aplpy";
  };

  nativeCheckInputs = [
    pytest-astropy
    pytestCheckHook
  ];

  preCheck = ''
    OPENMP_EXPECTED=0
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    matplotlib
    numpy
    pillow
    pyavm
    pyregion
    reproject
    scikit-image
    shapely
  ];

  pyproject = true;
  pythonImportsCheck = [ "aplpy" ];

  meta = {
    description = "Astronomical Plotting Library in Python";
    homepage = "http://aplpy.github.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ smaret ];
  };
}
