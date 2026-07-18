{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  django,
  nix-update-script,
  psycopg,
  python-dateutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-postgres-partition";
  version = "0.1.4";

  src = fetchFromGitLab {
    owner = "burke-software";
    repo = "django-postgres-partition";
    tag = version;
    hash = "sha256-Wk+m75gO9iClN9/vXGBl27VcmqyE6c1xpQX+X1qcKuU=";
  };

  # tests don't work yet, see https://gitlab.com/burke-software/django-postgres-partition/-/issues/4
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    django
    psycopg
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "psql_partition" ];
  pythonRelaxDeps = [ "django" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Partition support for django, based on django-postgres-extra";
    homepage = "https://gitlab.com/burke-software/django-postgres-partition";
    changelog = "https://gitlab.com/burke-software/django-postgres-partition/-/releases/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
