{
  lib,
  stdenv,
  # dependencies
  adbc-driver-manager,
  arrow-adbc,
  buildPythonPackage,
  fetchPypi,
  importlib-resources,
  pandas,
  pyarrow,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adbc-driver-sqlite";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-pMa0liYQ981nzXVMQt104YosEfq+7JSIxVAdc65i3GI=";
    pname = "adbc_driver_sqlite";
  };

  env.ADBC_SQLITE_LIBRARY = "libadbc_driver_sqlite${stdenv.hostPlatform.extensions.sharedLibrary}";

  preBuild = ''
    cp ${lib.getLib arrow-adbc}/lib/$ADBC_SQLITE_LIBRARY .
    chmod u+w $ADBC_SQLITE_LIBRARY
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pandas
    pyarrow
  ];

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
    "adbc_driver_sqlite"
  ];

  meta = {
    description = "ADBC driver for working with SQLite";
    homepage = "https://pypi.org/project/adbc-driver-sqlite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
