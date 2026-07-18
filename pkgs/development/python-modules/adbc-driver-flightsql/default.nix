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
  pname = "adbc-driver-flightsql";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-dfcD7vGBLDky5fRkPF4htWkLI99+CeiLcn95UqpVnyo=";
    pname = "adbc_driver_flightsql";
  };

  env.ADBC_FLIGHTSQL_LIBRARY = "libadbc_driver_flightsql${stdenv.hostPlatform.extensions.sharedLibrary}";

  preBuild = ''
    cp ${lib.getLib arrow-adbc}/lib/$ADBC_FLIGHTSQL_LIBRARY .
    chmod u+w $ADBC_FLIGHTSQL_LIBRARY
  '';

  # Tests require several unknown pytest fixtures such as `dremio` & `test_dbapi`
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
    "adbc_driver_flightsql"
  ];

  meta = {
    description = "ADBC driver for working with Apache Arrow Flight SQL";
    homepage = "https://pypi.org/project/adbc-driver-flightsql";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
