{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-reversion";
  version = "6.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-CqVOszRpT1Iv0jR0OXjGFNRap4XtxwphdyZ82q8G+Wc=";
    pname = "django_reversion";
  };

  # Tests assume the availability of a mysql/postgresql database
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "reversion" ];

  meta = {
    description = "Extension to the Django web framework that provides comprehensive version control facilities";
    homepage = "https://github.com/etianen/django-reversion";
    changelog = "https://github.com/etianen/django-reversion/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
