{
  lib,
  agate,
  buildPythonPackage,
  dbt-common,
  dbt-protos,
  fetchPypi,
  hatchling,
  mashumaro,
  protobuf,
  pytestCheckHook,
  pytz,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "dbt-adapters";
  version = "1.22.10";

  # missing tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-KPyp+cLzEHBs4CyPew8pftyhTWvZeteSiqxVr0zily8=";
    pname = "dbt_adapters";
  };

  # circular dependencies
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    agate
    dbt-common
    dbt-protos
    mashumaro
    protobuf
    pytz
    typing-extensions
  ]
  ++ mashumaro.optional-dependencies.msgpack;

  pyproject = true;
  pythonImportsCheck = [ "dbt.adapters" ];

  pythonRelaxDeps = [
    "mashumaro"
    "protobuf"
  ];

  meta = {
    description = "Set of adapter protocols and base functionality that supports integration with dbt-core";
    homepage = "https://github.com/dbt-labs/dbt-adapters";
    changelog = "https://github.com/dbt-labs/dbt-adapters/blob/main/dbt-adapters/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
