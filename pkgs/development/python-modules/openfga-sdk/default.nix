{
  lib,
  fetchFromGitHub,
  aiohttp,
  build,
  buildPythonPackage,
  hatchling,
  mock,
  opentelemetry-api,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  pythonAtLeast,
  urllib3,
}:

buildPythonPackage rec {
  pname = "openfga-sdk";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "openfga";
    repo = "python-sdk";
    tag = "v${version}";
    hash = "sha256-+LVlA+YPDCULpV+1jA+GTNh2YBLD7UrtbYVZemfB0kM=";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    build
    opentelemetry-api
    python-dateutil
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "openfga_sdk" ];

  meta = {
    description = "Fine-Grained Authorization solution for Python";
    homepage = "https://github.com/openfga/python-sdk";
    changelog = "https://github.com/openfga/python-sdk/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nicklewis ];
  };
}
