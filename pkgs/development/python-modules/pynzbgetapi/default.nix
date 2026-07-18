{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynzbgetapi";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ONwrlHEljiDa+/vRbSsHAEly+8Q3z87CwEzIiWedrm4=";
  };

  # No tests available in the repository
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pynzbgetapi"
  ];

  meta = {
    description = "Basic Python NZBGet API client";
    homepage = "https://github.com/voltron4lyfe/pynzbgetapi";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
