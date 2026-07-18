{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  httpretty,
  pytestCheckHook,
  requests,
  requests-kerberos,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "presto-python-client";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "prestodb";
    repo = "presto-python-client";
    tag = version;
    hash = "sha256-ZpVcmX6jRu4PJ1RxtIR8i0EpfhhhP8HZVVkB7CWLrsM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    httpretty
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    requests
    requests-kerberos
    six
  ];

  # Integration tests require network access
  disabledTestPaths = [ "integration_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "prestodb" ];

  meta = {
    description = "Client for Presto (https://prestodb.io), a distributed SQL engine for interactive and batch big data processing";
    homepage = "https://github.com/prestodb/presto-python-client";
    changelog = "https://github.com/prestodb/presto-python-client/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jherland ];
  };
}
