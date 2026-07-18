{
  lib,
  buildPythonPackage,
  # dependencies
  django,
  fetchPypi,
  pyscaffold,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyscaffoldext-django";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5yzF3VK/9VlCSrRsRJWX4arr9n34G2R6O5A51jTpLhg=";
  };

  doCheck = false; # tests require git checkout

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    django
    pyscaffold
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyscaffoldext.django" ];
  pythonRelaxDeps = [ "django" ];

  meta = {
    description = "Integration of django builtin scaffold cli (django-admin) into PyScaffold";
    homepage = "https://pypi.org/project/pyscaffoldext-django/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
