{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  # dependencies
  anyio,
  boto3,
  botocore,
  buildPythonPackage,
  # test
  dirty-equals,
  distro,
  docstring-parser,
  # optional dependencies
  google-auth,
  # build-system
  hatch-fancy-pypi-readme,
  hatchling,
  http-snapshot,
  httpx,
  httpx-aiohttp,
  inline-snapshot,
  jiter,
  nest-asyncio,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  respx,
  sniffio,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "anthropic";
  version = "0.109.1";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "anthropic-sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H+blENPgkKhoGPJmAtdszFsJDkAzgprlDso0o2fhwz8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"hatchling==1.26.3"' '"hatchling>=1.26.3"'
  '';

  nativeCheckInputs = [
    dirty-equals
    http-snapshot
    inline-snapshot
    nest-asyncio
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    respx
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    anyio
    distro
    docstring-parser
    httpx
    jiter
    pydantic
    sniffio
    typing-extensions
  ];

  disabledTestPaths = [
    # Test require network access
    "tests/api_resources"
    "tests/lib/test_bedrock.py"
  ];

  disabledTests = [
    # Test require network access
    "test_copy_build_request"
    # Tests try to launch bash and fail
    "test_bash_session_persistence"
    "test_bash_timeout"
    "test_bash_sentinel_not_spoofable"
    "test_bash_stdin_redirect"
    "test_bash_session_closed_property"
    "test_bash_outer_cancel_closes_subprocess_no_stale_state"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Hangs
    # https://github.com/anthropics/anthropic-sdk-python/issues/1008
    "test_get_platform"
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      httpx-aiohttp
    ];

    bedrock = [
      boto3
      botocore
    ];

    vertex = [ google-auth ] ++ google-auth.optional-dependencies.requests;
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "anthropic" ];

  meta = {
    description = "Anthropic's safety-first language model APIs";
    homepage = "https://github.com/anthropics/anthropic-sdk-python";
    changelog = "https://github.com/anthropics/anthropic-sdk-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.natsukium
      lib.maintainers.sarahec
    ];
  };
})
