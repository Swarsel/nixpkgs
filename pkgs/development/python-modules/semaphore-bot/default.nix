{
  lib,
  anyio,
  attrs,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "semaphore-bot";
  version = "0.17.0";

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-3zb6+HdOB6+YrVRcmIHsokFKUOlFmKCoVNllvM+aOXQ=";
  };

  # Upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    anyio
    attrs
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "semaphore" ];

  pythonRelaxDeps = [
    "anyio"
    "attrs"
    "python_dateutil"
  ];

  meta = {
    description = "Simple rule-based bot library for Signal Private Messenger";
    homepage = "https://github.com/lwesterhof/semaphore";
    license = with lib.licenses; [ agpl3Plus ];
    maintainers = with lib.maintainers; [ onny ];
  };
}
