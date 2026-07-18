{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-autoslug,
  django-extensions,
  hatchling,
  mock,
  mock-django,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-organizations";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "bennylope";
    repo = "django-organizations";
    tag = version;
    hash = "sha256-MgXB2gr7tWBXpgVfxLMI0RQWwAbhXlxdzyqk7XdEsWE=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
    mock
    mock-django
    django-autoslug
  ];

  build-system = [ hatchling ];

  dependencies = [
    django
    django-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "organizations" ];

  meta = {
    description = "Multi-user accounts for Django projects";
    homepage = "https://github.com/bennylope/django-organizations";
    changelog = "https://github.com/bennylope/django-organizations/blob/${version}/HISTORY.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
