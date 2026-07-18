{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pywebpush,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-webpush";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "safwanrahman";
    repo = "django-webpush";
    tag = version;
    hash = "sha256-Mwp53apdPpBcn7VfDbyDlvLAVAG65UUBhT0w9OKjKbU=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    django
    pywebpush
  ];

  pyproject = true;
  pythonImportsCheck = [ "webpush" ];
  pythonRelaxDeps = [ "pywebpush" ];

  meta = {
    description = "Module for integrating and sending Web Push Notification in Django Application";
    homepage = "https://github.com/safwanrahman/django-webpush/";
    changelog = "https://github.com/safwanrahman/django-webpush/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
