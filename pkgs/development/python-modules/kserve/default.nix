{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # logging
  asgi-logger,
  # tests
  avro,
  buildPythonPackage,
  cloudevents,
  cryptography,
  fastapi,
  grpc-interceptor,
  grpcio,
  grpcio-testing,
  grpcio-tools,
  h11,
  httpx,
  jinja2,
  # optional-dependencies
  # storage
  kserve-storage,
  kubernetes,
  numpy,
  orjson,
  pandas,
  prometheus-client,
  protobuf,
  psutil,
  pyasn1,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-httpx,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  python-multipart,
  pyyaml,
  # ray
  ray,
  # build-system
  setuptools,
  six,
  starlette,
  tabulate,
  timing-asgi,
  tomlkit,
  urllib3,
  uvicorn,
  # llm
  vllm,
}:

buildPythonPackage (finalAttrs: {
  pname = "kserve";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "kserve";
    repo = "kserve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i8eFdXwNLPTdEj2MnNAMbefxQGkMLHNwZXxg8+zv6v0=";
  };

  nativeCheckInputs = [
    avro
    grpcio-testing
    jinja2
    pytest-asyncio
    pytest-cov-stub
    pytest-httpx
    pytest-xdist
    pytestCheckHook
    tomlkit
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    cloudevents
    cryptography
    fastapi
    grpc-interceptor
    grpcio
    grpcio-tools
    h11
    httpx
    kubernetes
    numpy
    orjson
    pandas
    prometheus-client
    protobuf
    psutil
    pyasn1
    pydantic
    python-dateutil
    python-multipart
    pyyaml
    six
    starlette
    tabulate
    timing-asgi
    urllib3
    uvicorn
  ]
  ++ uvicorn.optional-dependencies.standard;

  disabledTestPaths = [
    # Looks for a config file at the root of the repository
    "test/test_inference_service_client.py"

    # AssertionError
    "test/test_server.py::TestTFHttpServerLoadAndUnLoad::test_unload"

    # Race condition when called concurrently between two instances of the same model (i.e. in nixpkgs-review)
    "test/test_dataplane.py::TestDataPlane::test_model_metadata[TEST_RAY_SERVE_MODEL]"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # RuntimeError: Failed to start GCS
    "test/test_dataplane.py::TestDataPlane::test_explain"
    "test/test_dataplane.py::TestDataPlane::test_infer"
    "test/test_dataplane.py::TestDataPlane::test_model_metadata"
    "test/test_dataplane.py::TestDataPlane::test_server_readiness"
    "test/test_server.py::TestRayServer::test_explain"
    "test/test_server.py::TestRayServer::test_health_handler"
    "test/test_server.py::TestRayServer::test_infer"
    "test/test_server.py::TestRayServer::test_list_handler"
    "test/test_server.py::TestRayServer::test_liveness_handler"
    "test/test_server.py::TestRayServer::test_predict"
    # Permission Error
    "test/test_server.py::TestMutiProcessServer::test_rest_server_multiprocess"
  ];

  disabledTests = [
    # AttributeError: 'google._upb._message.FieldDescriptor' object has no attribute 'label'
    "test_health_handler"
    "test_list_handler"
    "test_liveness_handler"
    "test_server_readiness"

    # Started failing since vllm was updated to 0.13.0
    # pydantic_core._pydantic_core.ValidationError: 1 validation error for RerankResponse
    # usage.prompt_tokens
    #   Field required [type=missing, input_value={'total_tokens': 100}, input_type=dict]
    #     For further information visit https://errors.pydantic.dev/2.11/v/missing
    "test_create_rerank"
    "test_create_embedding"

    # AssertionError: assert CompletionReq...lm_xargs=None) == CompletionReq...lm_xargs=None)
    "test_convert_params"

    # Flaky: ray.exceptions.ActorDiedError: The actor died unexpectedly before finishing this task.
    "test_explain"
    "test_infer"
    "test_predict"

    # Require network access
    "test_infer_graph_endpoint"
    "test_infer_path_based_routing"

    # Tries to access `/tmp` (hardcoded)
    "test_local_path_with_out_dir_exist"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_local_path_with_out_dir_not_exist"
  ];

  optional-dependencies = {
    llm = [
      vllm
    ];

    logging = [
      asgi-logger
    ];

    ray = [
      ray
    ]
    ++ ray.optional-dependencies.serve;

    storage = [
      kserve-storage
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "kserve" ];

  pythonRelaxDeps = [
    "cryptography"
    "fastapi"
    "httpx"
    "numpy"
    "prometheus-client"
    "protobuf"
    "psutil"
    "python-multipart"
    "starlette"
    "uvicorn"
  ];

  sourceRoot = "${finalAttrs.src.name}/python/kserve";

  meta = {
    description = "Standardized Serverless ML Inference Platform on Kubernetes";
    homepage = "https://github.com/kserve/kserve/tree/master/python/kserve";
    changelog = "https://github.com/kserve/kserve/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
