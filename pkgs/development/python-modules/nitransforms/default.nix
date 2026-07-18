{
  lib,
  buildPythonPackage,
  fetchPypi,
  h5py,
  nibabel,
  numpy,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "nitransforms";
  version = "25.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Wcs0iV/ENCLhsjH6hTDmxoAsNAN9qzd9n+wWbiA04aU=";
  };

  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    h5py
    nibabel
    numpy
    scipy
  ];

  pyproject = true;

  # relies on data repo (https://github.com/nipreps-data/nitransforms-tests);
  # probably too heavy
  pythonImportsCheck = [
    "nitransforms"
    "nitransforms.base"
    "nitransforms.io"
    "nitransforms.io.base"
    "nitransforms.linear"
    "nitransforms.manip"
    "nitransforms.nonlinear"
    "nitransforms.patched"
  ];

  meta = {
    description = "Geometric transformations for images and surfaces";
    homepage = "https://nitransforms.readthedocs.io";
    changelog = "https://github.com/nipy/nitransforms/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "nb-transform";
  };
}
