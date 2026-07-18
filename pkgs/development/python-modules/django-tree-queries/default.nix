{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  hatchling,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-tree-queries";
  version = "0.24";

  src = fetchFromGitHub {
    owner = "feincms";
    repo = "django-tree-queries";
    tag = version;
    hash = "sha256-VPJU/0tnnLSayJhuOO0YOtqegULF6CB6ve8/1ytFydA=";
  };

  nativeCheckInputs = [
    django
    pytest-cov-stub
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    pushd tests
    export DJANGO_SETTINGS_MODULE=testapp.settings
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tree_queries"
  ];

  meta = {
    description = "Adjacency-list trees for Django using recursive common table expressions. Supports PostgreSQL, sqlite, MySQL and MariaDB";
    homepage = "https://github.com/feincms/django-tree-queries";
    changelog = "https://github.com/feincms/django-tree-queries/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
