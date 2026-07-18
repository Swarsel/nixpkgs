{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-filter,
  djangorestframework,
  drf-spectacular,
  fetchpatch,
  flit-core,
  inflection,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "drf-standardized-errors";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "ghazi-git";
    repo = "drf-standardized-errors";
    tag = "v${version}";
    hash = "sha256-OM1bTqM3yQSPuerTrq5FKTf5eKpZsF6/QgupMtnnT4Q=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    django-filter
    drf-spectacular
  ];

  build-system = [ flit-core ];

  dependencies = [
    django
    djangorestframework
  ];

  optional-dependencies.openapi = [
    drf-spectacular
    inflection
  ];

  pyproject = true;
  pythonImportsCheck = [ "drf_standardized_errors" ];

  meta = {
    description = "Standardize your DRF API error responses";
    homepage = "https://github.com/ghazi-git/drf-standardized-errors";
    changelog = "https://github.com/ghazi-git/drf-standardized-errors/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
