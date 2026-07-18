{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  tqdm,
  wheel,
}:

buildPythonPackage rec {
  pname = "tiler";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ps0uHgzPa+ZoXXrB+0gfuVIEBUNmym/ym6xCxiyHhxA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    numpy
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "tiler" ];

  meta = {
    description = "N-dimensional NumPy array tiling and merging with overlapping, padding and tapering";
    homepage = "https://the-lay.github.io/tiler/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
