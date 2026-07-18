{
  lib,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "snaptime";
  version = "0.2.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4/HriQQ9WNMHIauYy2UCPxpMJ0DjsZdwQpixY8ktUIs=";
  };

  nativeBuildInputs = [ setuptools ];
  # no tests on Pypi, no tags on github
  doCheck = false;

  dependencies = [
    python-dateutil
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "snaptime" ];

  meta = {
    description = "Transform timestamps with a simple DSL";
    homepage = "https://github.com/zartstrom/snaptime";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
