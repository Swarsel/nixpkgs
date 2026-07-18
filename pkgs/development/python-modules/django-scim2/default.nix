{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagates
  django,
  # tests
  mock,
  # build-system
  poetry-core,
  pytest-django,
  pytestCheckHook,
  scim2-filter-parser,
}:

buildPythonPackage rec {
  pname = "django-scim2";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "15five";
    repo = "django-scim2";
    tag = version;
    hash = "sha256-OsfC6Jc/oQl6nzy3Nr3vkY+XicRxUoV62hK8MHa3LJ8=";
  };

  nativeCheckInputs = [
    mock
    pytest-django
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    django
    scim2-filter-parser
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_scim" ];

  meta = {
    description = "SCIM 2.0 Service Provider Implementation (for Django)";
    homepage = "https://github.com/15five/django-scim2";
    changelog = "https://github.com/15five/django-scim2/blob/${src.tag}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ s1341 ];
  };
}
