{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
  social-auth-core,
}:

buildPythonPackage rec {
  pname = "social-auth-app-django";
  version = "5.9.0";

  src = fetchFromGitHub {
    owner = "python-social-auth";
    repo = "social-app-django";
    tag = version;
    hash = "sha256-kyiN7HblqN66Slrub2IphCXBBy6UKxd7PbVHkjuHzkI=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    social-auth-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "social_django" ];

  meta = {
    description = "Module for social authentication/registration mechanism";
    homepage = "https://github.com/python-social-auth/social-app-django";
    changelog = "https://github.com/python-social-auth/social-app-django/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    broken = lib.versionOlder django.version "5.1";
  };
}
