{
  lib,
  buildPythonPackage,
  cachetools,
  fetchPypi,
  hatchling,
  pandas,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "world-bank-data";
  version = "0.1.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-UidtJovurzrZKWeI7n1bV0vluc5pSg92zKFELvZE9fw=";
    pname = "world_bank_data";
  };

  # Tests require a HTTP connection
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    cachetools
    pandas
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "world_bank_data"
  ];

  meta = {
    description = "World Bank Data API in Python";
    homepage = "https://github.com/mwouts/world_bank_data";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ itepastra ];
  };
}
