{
  lib,
  # dependencies
  aiohttp,
  aiohttp-jinja2,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  jinja2,
  rich,
  textual,
}:

buildPythonPackage rec {
  pname = "textual-serve";
  version = "1.1.3";

  # No tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-+PY2ri9f1lG3nZZUc8PpOD01Ic34lvm8KJcJGF2j9oM=";
    pname = "textual_serve";
  };

  # No tests in the pypi archive
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    aiohttp
    aiohttp-jinja2
    jinja2
    rich
    textual
  ];

  pyproject = true;

  pythonImportsCheck = [
    "textual_serve"
  ];

  meta = {
    description = "Turn your Textual TUIs in to web applications";
    homepage = "https://pypi.org/project/textual-serve/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
