{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  anthropic,
  # dependencies
  boto3,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain,
  langchain-anthropic,
  langchain-core,
  # tests
  langchain-tests,
  numpy,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-aws";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain-aws";
    tag = "langchain-aws==${finalAttrs.version}";
    hash = "sha256-MFlC9/9ZC1b5jAkvLRy2alcSYU5+KETJ6rIW05nLR5I=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--snapshot-warn-unused" ""
  '';

  nativeCheckInputs = [
    anthropic
    langchain-tests
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    boto3
    langchain
    langchain-core
    numpy
    pydantic
  ];

  disabledTests = [
    # Fails when langchain-core gets ahead of this package
    "test_serdes"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];

  optional-dependencies = {
    anthropic = anthropic.optional-dependencies.bedrock ++ [
      langchain-anthropic
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "langchain_aws" ];

  pythonRelaxDeps = [
    # Boto3 spec has outstripped the version requirement
    "boto3"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/aws";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-aws==";
    };
  };

  meta = {
    description = "Build LangChain application on AWS";
    homepage = "https://github.com/langchain-ai/langchain-aws/";
    changelog = "https://github.com/langchain-ai/langchain-aws/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
