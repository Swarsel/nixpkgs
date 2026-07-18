{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  netaddr,
  # required for tests
  postgresql,
  postgresqlTestHook,
  psycopg2,
  pytest-django,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "django-postgresql-netfields";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "jimfunk";
    repo = "django-postgresql-netfields";
    rev = "v${version}";
    hash = "sha256-oUmgV3MaEOYULvadHZgGYtshlIqYrvQpejYfeMzx1vg=";
  };

  propagatedBuildInputs = [
    django
    netaddr
    six
  ];

  env.DJANGO_SETTINGS_MODULE = "testsettings";
  doCheck = !stdenv.hostPlatform.isDarwin; # could not create shared memory segment: Operation not permitted

  nativeCheckInputs = [
    djangorestframework
    postgresql
    postgresqlTestHook
    psycopg2
    pytestCheckHook
    pytest-django
  ];

  format = "setuptools";
  postgresqlTestUserOptions = "LOGIN SUPERUSER";

  meta = {
    description = "Django PostgreSQL netfields implementation";
    homepage = "https://github.com/jimfunk/django-postgresql-netfields";
    changelog = "https://github.com/jimfunk/django-postgresql-netfields/blob/v${version}/CHANGELOG";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
