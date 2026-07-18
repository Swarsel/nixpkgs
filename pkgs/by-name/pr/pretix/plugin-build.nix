{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  gettext,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretix-plugin-build";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iLbqcCAbeK4PyLXiebpdE27rt6bOP7eXczIG2bdvvYo=";
  };

  doCheck = false; # no tests

  build-system = [
    setuptools
  ];

  dependencies = [
    django
    gettext
  ];

  pyproject = true;

  meta = {
    description = "";
    homepage = "https://github.com/pretix/pretix-plugin-build";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
