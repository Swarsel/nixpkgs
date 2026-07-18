{
  lib,
  buildPythonPackage,
  # dependencies
  django,
  fetchPypi,
  # tests
  jinja2,
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-csp";
  version = "4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-snAQu3Ausgo9rTKReN8rYaK4LTOLcPvcE8OjvShxKDM=";
    pname = "django_csp";
  };

  postPatch = ''
    sed -i "/addopts =/d" pyproject.toml
  '';

  nativeCheckInputs = [
    jinja2
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;

  meta = {
    description = "Adds Content-Security-Policy headers to Django";
    homepage = "https://github.com/mozilla/django-csp";
    license = lib.licenses.bsd3;
  };
}
