{
  lib,
  buildPythonPackage,
  colored,
  fetchPypi,
  h5py,
  hdf5plugin,
  numpy,
  pytestCheckHook,
  python-dateutil,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "nexusformat";
  version = "2.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uDHWO+nxfWe1d1eBona4fsqNDt0Swbkb513sSOPI9Sk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    colored
    h5py
    hdf5plugin
    numpy
    python-dateutil
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "nexusformat.nexus" ];

  meta = {
    description = "Python API to open, create, and manipulate NeXus data written in the HDF5 format";
    homepage = "https://github.com/nexpy/nexusformat";
    changelog = "https://github.com/nexpy/nexusformat/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ oberth-effect ];
  };
}
