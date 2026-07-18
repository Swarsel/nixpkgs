{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-allowed-hosts";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LL0Vm33R0BYo8IKyjAzpvO7ls4EfcPx3cx3OU6OsE6s=";
    pname = "flask_allowed_hosts";
  };

  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flask_allowed_hosts" ];

  meta = {
    description = "Flask extension that helps you limit access to your API endpoints";
    homepage = "https://github.com/riad-azz/flask-allowedhosts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
