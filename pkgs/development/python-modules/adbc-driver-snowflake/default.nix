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
  pname = "adbc-driver-snowflake";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-f85UrnVAxsY6rWzJ7CeVoFZHzBR8ivQcor1OlUVejq4=";
    pname = "adbc_driver_snowflake";
  };

  env.ADBC_SNOWFLAKE_LIBRARY = "libadbc_driver_snowflake${stdenv.hostPlatform.extensions.sharedLibrary}";

  preBuild = ''
    cp ${lib.getLib arrow-adbc}/lib/$ADBC_SNOWFLAKE_LIBRARY .
    chmod u+w $ADBC_SNOWFLAKE_LIBRARY
  '';

  # Tests don't work - they require an unknown pytest fixture `snowflake`
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
    "adbc_driver_snowflake"
  ];

  meta = {
    description = "ADBC driver for working with Snowflake";
    homepage = "https://pypi.org/project/adbc-driver-snowflake";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
