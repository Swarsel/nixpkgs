{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  psycopg,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-tenants";
  version = "3.11.2";

  src = fetchFromGitHub {
    owner = "django-tenants";
    repo = "django-tenants";
    tag = "v${version}";
    hash = "sha256-J7poXEHbRxhULYwFbV4tktet5wdsvd7RNHgivETy9+8=";
  };

  build-system = [ setuptools ];

  dependencies = [
    django
    psycopg
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_tenants" ];

  meta = {
    description = "Django tenants using PostgreSQL Schemas";
    homepage = "https://github.com/django-tenants/django-tenants";
    changelog = "https://github.com/django-tenants/django-tenants/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
