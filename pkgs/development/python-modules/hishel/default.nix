{
  lib,
  fetchFromGitHub,
  anyio,
  anysqlite,
  buildPythonPackage,
  fakeredis,
  fastapi,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  inline-snapshot,
  msgpack,
  pytest-asyncio,
  pytestCheckHook,
  redis,
  redisTestHook,
  requests,
  time-machine,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "hishel";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "karpetrosyan";
    repo = "hishel";
    tag = version;
    hash = "sha256-aD6sHMM7dzy6n1EJN/+K+7H5nu5ohGfru224pSAf1Nc=";
  };

  postPatch = ''
    sed -i "/addopts/d" pyproject.toml
  '';

  nativeCheckInputs = [
    inline-snapshot
    pytest-asyncio
    pytestCheckHook
    redisTestHook
    fakeredis
    time-machine
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    msgpack
    typing-extensions
  ];

  disabledTests = [
    # network access
    "test_encoded_content_caching"
    "test_simple_caching"
    "test_simple_caching_ignoring_spec"
  ];

  optional-dependencies = {
    async = [
      anyio
      anysqlite
    ];

    fastapi = [ fastapi ];
    httpx = [ httpx ];
    redis = [ redis ];
    requests = [ requests ];
  };

  pyproject = true;
  pythonImportsCheck = [ "hishel" ];

  meta = {
    description = "HTTP Cache implementation for HTTPX and HTTP Core";
    homepage = "https://github.com/karpetrosyan/hishel";
    changelog = "https://github.com/karpetrosyan/hishel/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
