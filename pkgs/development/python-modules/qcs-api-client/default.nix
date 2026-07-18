{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  fetchpatch,
  httpx,
  iso8601,
  poetry-core,
  pydantic,
  pydantic-settings,
  pyjwt,
  pytest-asyncio,
  pytestCheckHook,
  python-dateutil,
  pythonAtLeast,
  respx,
  retrying,
  rfc3339,
  tenacity,
  toml,
}:

buildPythonPackage rec {
  pname = "qcs-api-client";
  version = "0.26.5";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "qcs-api-client-python";
    tag = "v${version}";
    hash = "sha256-8ZD/vqWA1QnEQXz6P/+NIxe0go1Q/XQ3iRNL/TkoTmM=";
  };

  patches = [
    # Switch to poetry-core, https://github.com/rigetti/qcs-api-client-python/pull/2
    (fetchpatch {
      hash = "sha256-mOc+Q/5cmwPziojtxeEMWWHSDvqvzZlNRbPtOSeTinQ=";
      name = "switch-to-poetry-core.patch";
      url = "https://github.com/rigetti/qcs-api-client-python/commit/32f0b3c7070a65f4edf5b2552648d88435469e44.patch";
    })
  ];

  # Tests are failing on Python 3.11, Fatal Python error: Aborted
  doCheck = !(pythonAtLeast "3.11");

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    respx
  ];

  build-system = [ poetry-core ];

  dependencies = [
    attrs
    httpx
    iso8601
    pydantic
    pydantic-settings
    pyjwt
    python-dateutil
    retrying
    rfc3339
    tenacity
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "qcs_api_client" ];

  pythonRelaxDeps = [
    "attrs"
    "httpx"
    "iso8601"
    "pydantic"
    "tenacity"
  ];

  meta = {
    description = "Python library for accessing the Rigetti QCS API";
    homepage = "https://qcs-api-client-python.readthedocs.io/";
    changelog = "https://github.com/rigetti/qcs-api-client-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
