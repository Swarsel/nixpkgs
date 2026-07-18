{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pushover-complete";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-JPx9hNc0JoQOdnj+6A029A3wEUyzA1K6T5mrOELtIac=";
    pname = "pushover_complete";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-toolbelt
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pushover_complete" ];

  meta = {
    description = "Python package for interacting with *all* aspects of the Pushover API";
    homepage = "https://github.com/scolby33/pushover_complete";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mic92 ];
  };
}
