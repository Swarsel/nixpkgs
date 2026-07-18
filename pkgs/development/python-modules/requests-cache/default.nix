{
  lib,
  fetchFromGitHub,
  attrs,
  boto3,
  botocore,
  buildPythonPackage,
  cattrs,
  hatchling,
  itsdangerous,
  orjson,
  platformdirs,
  psutil,
  pymongo,
  pytest-rerunfailures,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  redis,
  requests,
  requests-mock,
  responses,
  rich,
  tenacity,
  time-machine,
  ujson,
  url-normalize,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "requests-cache";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "requests-cache";
    repo = "requests-cache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qil5z54kkxu8QlPQ2P/7jo+VyfC+KhhiSUyAVmuLG/o=";
  };

  nativeCheckInputs = [
    psutil
    pytestCheckHook
    pytest-rerunfailures
    pytest-xdist
    requests-mock
    responses
    rich
    tenacity
    time-machine
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  build-system = [ hatchling ];

  dependencies = [
    attrs
    cattrs
    platformdirs
    requests
    urllib3
    url-normalize
  ];

  disabledTests = [
    # Flaky
    "test_request_only_if_cached__stale_if_error__expired"
  ];

  enabledTestPaths = [
    # Integration tests require local DBs
    "tests/unit"
  ];

  optional-dependencies = {
    all = [
      orjson
      ujson
    ]
    ++ lib.concatAttrValues (lib.removeAttrs finalAttrs.passthru.optional-dependencies [ "all" ]);

    dynamodb = [
      boto3
      botocore
    ];

    mongodb = [ pymongo ];
    redis = [ redis ];
    security = [ itsdangerous ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "requests_cache" ];

  meta = {
    description = "Persistent cache for requests library";
    homepage = "https://github.com/reclosedev/requests-cache";
    changelog = "https://github.com/requests-cache/requests-cache/blob/$v{finalAttrs.version}/HISTORY.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
