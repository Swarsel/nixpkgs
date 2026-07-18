{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  click,
  cryptography,
  dotmap,
  ecs-logging,
  elastic-transport,
  elasticsearch8,
  hatchling,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  requests,
  tiered-debug,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "es-client";
  version = "9.0.2";

  src = fetchFromGitHub {
    owner = "untergeek";
    repo = "es_client";
    tag = "v${version}";
    hash = "sha256-83EBDmbZuOAVT2oYn98s6XTZrB38lx03nozAkBqHfgg=";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
    requests
  ];

  build-system = [ hatchling ];

  dependencies = [
    certifi
    click
    cryptography
    dotmap
    ecs-logging
    elastic-transport
    elasticsearch8
    pyyaml
    tiered-debug
    voluptuous
  ];

  disabledTests = [
    # Tests require local Elasticsearch instance
    "test_bad_version_raises"
    "test_basic_operation"
    "test_client_info"
    "test_client_info"
    "test_exit_if_not_master"
    "test_multiple_hosts_raises"
    "test_skip_version_check"
    "TestCLIExample"
  ];

  pyproject = true;
  pythonImportsCheck = [ "es_client" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Module for building Elasticsearch client objects";
    homepage = "https://github.com/untergeek/es_client";
    changelog = "https://github.com/untergeek/es_client/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
