{
  lib,
  fetchFromGitHub,
  asgiref,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-htmx";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "django-htmx";
    tag = version;
    hash = "sha256-5Z/Ji1J6ofOHG64aj9bsHEw6EBELFQ4Lwsn8vGQUFe8=";
  };

  buildInputs = [ django ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  build-system = [ setuptools ];
  dependencies = [ asgiref ];
  pyproject = true;
  pythonImportsCheck = [ "django_htmx" ];

  meta = {
    description = "Extensions for using Django with htmx";
    homepage = "https://github.com/adamchainz/django-htmx";
    changelog = "https://github.com/adamchainz/django-htmx/blob/${src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
  };
}
