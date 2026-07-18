{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  ipywidgets,
  jupyterlab,
}:

buildPythonPackage rec {
  pname = "ipylab";
  version = "1.1.0";

  # This needs to be fetched from Pypi, as we rely on the nodejs build to be skipped,
  # which only happens if ipylab/labextension/style.js is present.
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-85hYpNnvbsuC+O/uufa1oBo6ZNTzxPKl/i1YrllN4hI=";
  };

  # There are no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-jupyter-builder
    hatch-nodejs-version
    jupyterlab
  ];

  dependencies = [
    ipywidgets
  ];

  pyproject = true;
  pythonImportsCheck = [ "ipylab" ];

  meta = {
    description = "Control JupyterLab from Python notebooks";
    homepage = "https://github.com/jtpio/ipylab";
    changelog = "https://github.com/jtpio/ipylab/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
