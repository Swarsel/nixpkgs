{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  coverage,
  # dependencies
  django,
  pytest-django,
  pytest-randomly,
  pytestCheckHook,
  rich,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-rich";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "django-rich";
    tag = finalAttrs.version;
    hash = "sha256-Nd787s55ozqiSGdU8/2S3xbPF0rJuLTyvGqs8Fhu3n8=";
  };

  nativeCheckInputs = [
    coverage
    pytest-django
    pytest-randomly
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_rich" ];

  meta = {
    description = "Extensions for using Rich with Django";
    homepage = "https://github.com/adamchainz/django-rich";
    changelog = "https://github.com/adamchainz/django-rich/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kilyanni ];
  };
})
