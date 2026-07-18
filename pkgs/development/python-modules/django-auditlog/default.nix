{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  freezegun,
  postgresql,
  postgresqlTestHook,
  psycopg2,
  python,
  python-dateutil,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-auditlog";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-auditlog";
    tag = "v${version}";
    hash = "sha256-/IOzMGRR8EP/AGP7fcqwP4GeSKXPwE6NF6AZmiF1+lA=";
  };

  doCheck = stdenv.hostPlatform.isLinux; # postgres fails to allocate shm on darwin

  nativeCheckInputs = [
    freezegun
    psycopg2
    postgresql
    postgresqlTestHook
  ];

  checkPhase = ''
    runHook preCheck

    cd auditlog_tests
    # strip escape codes otherwise tests fail
    # see https://github.com/jazzband/django-auditlog/issues/644
    TEST_DB_USER=$PGUSER \
    TEST_DB_HOST=$PGHOST \
    ${python.interpreter} ./manage.py test | cat
    cd ..

    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    django
    python-dateutil
  ];

  postgresqlTestUserOptions = "LOGIN SUPERUSER";
  pyproject = true;
  pythonImportsCheck = [ "auditlog" ];

  meta = {
    description = "Django app that keeps a log of changes made to an object";
    homepage = "https://github.com/jazzband/django-auditlog";
    changelog = "https://github.com/jazzband/django-auditlog/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ leona ];
    downloadPage = "https://github.com/jazzband/django-auditlog";
  };
}
