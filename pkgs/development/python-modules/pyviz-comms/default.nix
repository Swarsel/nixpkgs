{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  panel,
  param,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyviz-comms";
  version = "3.0.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-c9ZrYgOQ2XlZssTYosB3jUH+IFgb5HF/AeRrj66MVpU=";
    pname = "pyviz_comms";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"jupyterlab>=4.0.0,<5",' ""
  '';

  # there are not tests with the package
  doCheck = false;

  build-system = [
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
  ];

  dependencies = [ param ];
  pyproject = true;
  pythonImportsCheck = [ "pyviz_comms" ];

  passthru.tests = {
    inherit panel;
  };

  meta = {
    description = "Bidirectional communication for the HoloViz ecosystem";
    homepage = "https://pyviz.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
