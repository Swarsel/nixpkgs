{
  lib,
  aiohttp,
  blinker,
  buildPythonPackage,
  cloudpickle,
  dill,
  fetchPypi,
  h5py,
  matplotlib,
  msgpack,
  numpy,
  plotly,
  python,
  python-socketio,
  scipy,
  setuptools,
  versioningit,
}:

buildPythonPackage rec {
  pname = "bumps";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-O5GUoyDlB0X2Z/O3JprN3omoOBDIhv0xrKfUSHTgGpM=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    setuptools
    versioningit
  ];

  dependencies = [
    aiohttp
    blinker
    cloudpickle
    dill
    h5py
    matplotlib
    msgpack
    numpy
    plotly
    python
    python-socketio
    scipy
    # mpld3 # not packaged
  ];

  pyproject = true;
  pythonImportsCheck = [ "bumps" ];

  pythonRemoveDeps = [
    "mpld3" # not packaged
  ];

  meta = {
    description = "Data fitting with bayesian uncertainty analysis";
    homepage = "https://bumps.readthedocs.io/";
    changelog = "https://github.com/bumps/bumps/releases/tag/v${version}";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ rprospero ];
    mainProgram = "bumps";
  };
}
