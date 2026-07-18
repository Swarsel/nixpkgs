{
  lib,
  # propagates
  aiohttp,
  aiohttp-retry,
  authlib,
  buildPythonPackage,
  fetchPypi,
  # tests
  openapi-spec-validator,
  # build
  pdm-backend,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  toml,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "kanidm";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KlUxW/bJByQnzPdRd9Z5pStH27SpWrCijZc5jlVT5jE=";
  };

  nativeCheckInputs = [
    openapi-spec-validator
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    aiohttp
    aiohttp-retry
    authlib
    pydantic
    python-dateutil
    toml
    typing-extensions
  ];

  disabledTestMarks = [
    "network"
    "openapi"
  ];

  disabledTests = [
    "test_tokenstuff"
  ];

  pyproject = true;
  pythonImportsCheck = [ "kanidm" ];

  meta = {
    description = "Kanidm client library";
    homepage = "https://github.com/kanidm/kanidm/tree/master/pykanidm";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      arianvp
      hexa
    ];
  };
}
