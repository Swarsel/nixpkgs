{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  snowflake-connector-python,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "snowflake-sqlalchemy";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "snowflakedb";
    repo = "snowflake-sqlalchemy";
    tag = "v${version}";
    hash = "sha256-HxETZOHGfVcjopnoi8h37qanJa4pbjAmBk08u7HLRvA=";
  };

  # Tests require a database
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    snowflake-connector-python
    sqlalchemy
  ];

  pyproject = true;
  pythonImportsCheck = [ "snowflake.sqlalchemy" ];

  meta = {
    description = "Snowflake SQLAlchemy Dialect";
    homepage = "https://github.com/snowflakedb/snowflake-sqlalchemy";
    changelog = "https://github.com/snowflakedb/snowflake-sqlalchemy/blob/${src.tag}/DESCRIPTION.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
