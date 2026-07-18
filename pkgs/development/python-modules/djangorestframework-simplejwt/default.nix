{
  lib,
  buildPythonPackage,
  cryptography,
  django,
  djangorestframework,
  fetchPypi,
  pyjwt,
  python-jose,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "djangorestframework-simplejwt";
  version = "5.5.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5yxVcvUdeAMCEojiBXr8vQPxf+EdSECW9ApGCrx26H8=";
    pname = "djangorestframework_simplejwt";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    django
    djangorestframework
    pyjwt
  ];

  # Test raises django.core.exceptions.ImproperlyConfigured
  doCheck = false;
  format = "setuptools";

  optional-dependencies = {
    crypto = [ cryptography ];
    python-jose = [ python-jose ];
  };

  pythonImportsCheck = [ "rest_framework_simplejwt" ];

  meta = {
    description = "JSON Web Token authentication plugin for Django REST Framework";
    homepage = "https://github.com/davesque/django-rest-framework-simplejwt";
    changelog = "https://github.com/jazzband/djangorestframework-simplejwt/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
