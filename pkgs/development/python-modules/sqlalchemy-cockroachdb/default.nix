{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "sqlalchemy-cockroachdb";
  version = "2.0.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9mNU0rk9qJy0UkxbeKRNDPWolD0yi38K7kqh38YXi2U=";
    pname = "sqlalchemy_cockroachdb";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    sqlalchemy
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlalchemy_cockroachdb" ];

  meta = {
    description = "CockroachDB dialect for SQLAlchemy";
    homepage = "https://github.com/cockroachdb/sqlalchemy-cockroachdb/tree/master/sqlalchemy_cockroachdb";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pinpox ];
  };
}
