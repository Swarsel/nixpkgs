{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  djangorestframework,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "djangorestframework-dataclasses";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "oxan";
    repo = "djangorestframework-dataclasses";
    tag = "v${version}";
    hash = "sha256-nUkR5xTyeBv7ziJ6Mej9TKvMOa5/k+ELBqt4BVam/wk=";
  };

  postPatch = ''
    patchShebangs manage.py
  '';

  env.DJANGO_SETTINGS_MODULE = "tests.django_settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ djangorestframework ];
  pyproject = true;
  pythonImportsCheck = [ "rest_framework_dataclasses" ];

  meta = {
    description = "Dataclasses serializer for Django REST framework";
    homepage = "https://github.com/oxan/djangorestframework-dataclasses";
    changelog = "https://github.com/oxan/djangorestframework-dataclasses/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
