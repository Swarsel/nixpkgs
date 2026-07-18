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
  pname = "adbc-driver-bigquery";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-N/wqkN/sH3Qbx0db31DHRMItBewTXQhYk0EXkSwGB34=";
    pname = "adbc_driver_bigquery";
  };

  env.ADBC_BIGQUERY_LIBRARY = "libadbc_driver_bigquery${stdenv.hostPlatform.extensions.sharedLibrary}";

  preBuild = ''
    cp ${lib.getLib arrow-adbc}/lib/$ADBC_BIGQUERY_LIBRARY .
    chmod u+w $ADBC_BIGQUERY_LIBRARY
  '';

  # Tests don't work - they require an unknown pytest fixture `bigquery_auth_type`
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
    "adbc_driver_bigquery"
  ];

  meta = {
    description = "ADBC driver for working with BigQuery";
    homepage = "https://pypi.org/project/adbc-driver-bigquery";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
