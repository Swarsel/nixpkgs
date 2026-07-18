{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  pycognito,
  python-dateutil,
  # propagated modules
  requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyemvue";
  version = "0.18.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iHnNR6c/EdKZzqs4zQodfEZ/FMj1j0JRKjktyq/H0o0=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    requests
    python-dateutil
    pycognito
    typing-extensions
  ];

  # has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pyemvue" ];

  meta = {
    description = "Python library for reading data from the Emporia Vue energy monitoring system";
    homepage = "https://github.com/magico13/PyEmVue";
    changelog = "https://github.com/magico13/PyEmVue/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ presto8 ];
  };
}
