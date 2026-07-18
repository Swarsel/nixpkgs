{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  flit-core,
  pytest-unmagic,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-cte";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "dimagi";
    repo = "django-cte";
    tag = "v${version}";
    hash = "sha256-pXTnk3Z+6jiqq7Q2JTpHxZSNHaTRT3lAAeuHTQIuzBM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-unmagic
  ];

  build-system = [
    flit-core
  ];

  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "django_cte" ];

  meta = {
    description = "Common Table Expressions (CTE) for Django";
    homepage = "https://github.com/dimagi/django-cte";
    changelog = "https://github.com/dimagi/django-cte/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
