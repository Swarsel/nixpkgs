{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-multiselectfield";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-P4tP/z4H1Kkci7S4Cbw1yusitBdptgb0ye3FO41ypmc=";
    pname = "django_multiselectfield";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "multiselectfield" ];

  meta = {
    description = "Multiple Choice model field for Django";
    homepage = "https://github.com/goinnn/django-multiselectfield";
    changelog = "https://github.com/goinnn/django-multiselectfield/blob/master/CHANGES.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
