{
  lib,
  # dependencies
  aiolimiter,
  # optional-dependencies
  # azure
  azure-identity,
  azure-storage-blob,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  httpx,
  json-repair,
  # openai
  openai,
  # tests
  polyfactory,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonAtLeast,
  tenacity,
  tiktoken,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "fnllm";
  version = "0.4.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-gKdFBpNpG/CDLhKi1wQgZHv+o1pDy5HEqcteLzkXK1A=";
  };

  nativeCheckInputs = [
    polyfactory
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    aiolimiter
    httpx
    json-repair
    pydantic
    tenacity
  ];

  disabledTests = [
    # Tests require network access
    "chat"
    "embeddings"
    "rate_limited"
    "test_default_operations"
    "test_estimate_request_tokens"
    "test_replace_value"
    "test_text_service_encode_decode"
    "test_count_tokens"
    "trim_to_max_tokens"
    "test_split"
    "test_clear"
    "test_handles_common_errors"
    "test_children"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # RuntimeError: There is no current event loop in thread 'MainThread'
    "test_call_batch_raises_if_response_length_mismatch"
  ];

  optional-dependencies = {
    azure = [
      azure-identity
      azure-storage-blob
    ];

    openai = [
      openai
      tiktoken
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fnllm" ];

  meta = {
    description = "Function-based LLM protocol and wrapper";
    homepage = "https://github.com/microsoft/essex-toolkit/tree/main/python/fnllm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
