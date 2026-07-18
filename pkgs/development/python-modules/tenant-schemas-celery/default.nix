{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tenant-schemas-celery";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "maciej-gol";
    repo = "tenant-schemas-celery";
    tag = version;
    hash = "sha256-HLZQHwGCYYxU6LYvPoVhGeN8t5wqGVaXU44/qazf2aM=";
  };

  build-system = [ setuptools ];
  dependencies = [ celery ];
  pyproject = true;
  pythonImportsCheck = [ "tenant_schemas_celery" ];

  meta = {
    description = "Celery application implementation that allows celery tasks to cooperate with multi-tenancy provided by django-tenant-schemas and django-tenants packages";
    homepage = "https://github.com/maciej-gol/tenant-schemas-celery";
    changelog = "https://github.com/maciej-gol/tenant-schemas-celery/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
