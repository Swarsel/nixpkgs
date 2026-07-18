{
  lib,
  buildPythonPackage,
  fetchPypi,
  inflect,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "decora-wifi";
  version = "1.5";

  #No tag in github, so fetchPypi is OK to use.
  src = fetchPypi {
    inherit version;
    hash = "sha256-oWETtzZueNJC0lTWdLfk3SOuvnqrJ9wp5rOSPJxH3M4=";
    pname = "decora_wifi";
  };

  # No tests in Pypi source
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    inflect
  ];

  pyproject = true;
  pythonImportsCheck = [ "decora_wifi" ];

  meta = {
    description = "Python library for controlling Leviton Decora Smart Wi-Fi devices";
    homepage = "https://github.com/tlyakhov/python-decora_wifi";
    changelog = "https://github.com/tlyakhov/python-decora_wifi/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Continous ];
  };
}
