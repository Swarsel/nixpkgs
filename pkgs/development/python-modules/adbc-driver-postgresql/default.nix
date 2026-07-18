{
  lib,
  stdenv,
  # dependencies
  adbc-driver-manager,
  arrow-adbc,
  buildPythonPackage,
  fetchPypi,
  importlib-resources,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adbc-driver-postgresql";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9WiLhkiseobYuJNAIxuzaGrF31buldHKC4ddrV1StIo=";
    pname = "adbc_driver_postgresql";
  };

  env.ADBC_POSTGRESQL_LIBRARY = "libadbc_driver_postgresql${stdenv.hostPlatform.extensions.sharedLibrary}";

  preBuild = ''
    cp ${lib.getLib arrow-adbc}/lib/$ADBC_POSTGRESQL_LIBRARY .
    chmod u+w $ADBC_POSTGRESQL_LIBRARY
  '';

  # Tests require several unknown pytest fixture `postgres_uri`
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    adbc-driver-manager
    importlib-resources
  ];

  pyproject = true;

  pythonImportsCheck = [
    "adbc_driver_postgresql"
  ];

  meta = {
    description = "libpq-based ADBC driver for working with PostgreSQL";
    homepage = "https://pypi.org/project/adbc-driver-postgresql";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
