{
  lib,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "eufylife-ble-client";
  version = "0.1.10";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hfUsFifkwr5qhYM6Otlxo4AAGu967p/eWCR+yBrC4eM=";
    pname = "eufylife_ble_client";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    bleak
    bleak-retry-connector
    cryptography
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "eufylife_ble_client" ];

  meta = {
    description = "Module for parsing data from Eufy smart scales";
    homepage = "https://github.com/bdr99/eufylife-ble-client";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
