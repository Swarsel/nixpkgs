{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-cache-url";
  version = "3.4.6";

  src = fetchFromGitHub {
    owner = "epicserve";
    repo = "django-cache-url";
    tag = "v${version}";
    hash = "sha256-nXn/aDTMla4Pi6v93LoElxCpL6AFbbWKTd4TMFaK+Nk=";
  };

  nativeCheckInputs = [
    django
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "django_cache_url" ];

  meta = {
    description = "Use Cache URLs in your Django application";
    homepage = "https://github.com/epicserve/django-cache-url";
    changelog = "https://github.com/epicserve/django-cache-url/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
