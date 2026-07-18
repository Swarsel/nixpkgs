{
  lib,
  before-after,
  buildPythonPackage,
  dill,
  django,
  fetchPypi,
  funcy,
  jinja2,
  mock,
  net-tools,
  pkgs,
  pytest-django,
  pytestCheckHook,
  redis,
  redisTestHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "django-cacheops";
  version = "7.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-y8EcwDISlaNkTie8smlA8Iy5wucdPuUGy8/wvdoanzM=";
    pname = "django_cacheops";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    mock
    dill
    jinja2
    before-after
    net-tools
    pkgs.valkey
    redisTestHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    django
    funcy
    redis
    six
  ];

  pyproject = true;
  pythonRelaxDeps = [ "funcy" ];

  meta = {
    description = "Slick ORM cache with automatic granular event-driven invalidation for Django";
    homepage = "https://github.com/Suor/django-cacheops";
    changelog = "https://github.com/Suor/django-cacheops/blob/${version}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
