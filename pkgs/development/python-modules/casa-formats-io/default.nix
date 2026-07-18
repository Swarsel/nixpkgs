{
  lib,
  astropy,
  buildPythonPackage,
  dask,
  fetchPypi,
  numpy,
  oldest-supported-numpy,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "casa-formats-io";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FpQj0XeZ7vvOzUM/+5qG6FRwNXl3gzoUBItYdQ1M4m4=";
    pname = "casa_formats_io";
  };

  nativeBuildInputs = [ oldest-supported-numpy ];
  # Tests require a large (800 Mb) dataset
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    astropy
    dask
    numpy
  ];

  format = "setuptools";
  prproject = true;
  pythonImportsCheck = [ "casa_formats_io" ];

  meta = {
    description = "Dask-based reader for CASA data";
    homepage = "https://casa-formats-io.readthedocs.io/";
    changelog = "https://github.com/radio-astro-tools/casa-formats-io/blob/v${version}/CHANGES.rst";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ smaret ];
  };
}
