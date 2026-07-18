{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  cron-descriptor,
  django,
  django-timezone-field,
  fakeredis,
  mock,
  pytestCheckHook,
  python-crontab,
  python-dateutil,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "celery-redbeat";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "celery";
    repo = "django-celery-beat";
    tag = "v${version}";
    hash = "sha256-UGKMSXB+Hg865sAk5ePc/noO3eNTr7b3pp7tvNvn1T8=";
  };

  postPatch = ''
    # Hack the custom dependency resolution in setup.py to avoid pulling in pip
    substituteInPlace setup.py \
      --replace-fail "install_requires=reqs('default.txt') + reqs('runtime.txt')," "install_requires=[],"
  '';

  # Tests require additional work
  doCheck = false;

  nativeCheckInputs = [
    mock
    pytestCheckHook
    pytz
  ];

  build-system = [ setuptools ];

  dependencies = [
    celery
    cron-descriptor
    django
    django-timezone-field
    python-crontab
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_celery_beat" ];

  meta = {
    description = "Database-backed Periodic Tasks";
    homepage = "https://github.com/celery/django-celery-beat";
    changelog = "https://github.com/celery/django-celery-beat/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
