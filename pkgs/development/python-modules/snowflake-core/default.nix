{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pydantic,
  python-dateutil,
  pyyaml,
  requests,
  snowflake-connector-python,
  urllib3,
}:

buildPythonPackage rec {
  pname = "snowflake-core";
  version = "1.12.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bLECcQHXxtoS/vZQQf8qUahaOU27HwrAlQAMoFTyan4=";
    pname = "snowflake_core";
  };

  # Tests require access to Snowflake
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    pydantic
    python-dateutil
    pyyaml
    requests
    snowflake-connector-python
    urllib3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "snowflake.core"
  ];

  pythonRelaxDeps = [
    "pyopenssl"
  ];

  meta = {
    description = "Subpackage providing Python access to Snowflake entity metadata";
    homepage = "https://pypi.org/project/snowflake.core";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vtimofeenko ];
  };
}
