{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  # dependencies
  thrift,
}:

buildPythonPackage rec {
  pname = "hive-metastore-client";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "quintoandar";
    repo = "hive-metastore-client";
    tag = version;
    hash = "sha256-IejsiC1eDNa6fjpQPhLNkMvZpyr9QsQdGBfhev1jEyg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    thrift
  ];

  pyproject = true;
  pythonImportsCheck = [ "hive_metastore_client" ];

  pythonRelaxDeps = [
    "thrift"
  ];

  meta = {
    description = "Client for connecting and running DDLs on hive metastore";
    homepage = "https://github.com/quintoandar/hive-metastore-client";
    changelog = "https://github.com/quintoandar/hive-metastore-client/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
