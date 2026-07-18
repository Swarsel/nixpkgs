{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-stubs,
  hatch-vcs,
  hatchling,
  parameterized,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-modeltranslation";
  version = "0.20.3";

  src = fetchFromGitHub {
    owner = "deschler";
    repo = "django-modeltranslation";
    tag = "v${version}";
    hash = "sha256-DlghTCh2bcY+jHOYhQWVzMRGNKRIiQkLt4ZHDLVxUUs=";
  };

  nativeCheckInputs = [
    django-stubs
    pytestCheckHook
    pytest-cov-stub
    pytest-django
    parameterized
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "modeltranslation" ];

  meta = {
    description = "Translates Django models using a registration approach";
    homepage = "https://github.com/deschler/django-modeltranslation";
    changelog = "https://github.com/deschler/django-modeltranslation/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ augustebaum ];
  };
}
