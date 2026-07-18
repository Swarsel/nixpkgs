{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cbor2,
  certifi,
  click,
  fastapi,
  flaky,
  grpcio-tools,
  grpclib,
  httpx,
  invoke,
  ipython,
  mypy,
  mypy-protobuf,
  protobuf,
  pyjwt,
  pytest-asyncio,
  pytest-env,
  pytest-markdown-docs,
  pytest-timeout,
  pytestCheckHook,
  python-dotenv,
  rich,
  ruff,
  setuptools,
  six,
  synchronicity,
  toml,
  typer,
  types-certifi,
  types-toml,
  typing-extensions,
  watchfiles,
}:

buildPythonPackage (finalAttrs: {
  pname = "modal";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "modal-labs";
    repo = "modal-client";
    tag = "py/v${finalAttrs.version}";
    hash = "sha256-MXaiei2hUBwI9qlB7HZtWbnrsZq/iLnZgqIejn2ZgX8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail 'setuptools~=77.0.3' setuptools
    patchShebangs protoc_plugin/plugin.py
    inv protoc
    inv type-stubs
  '';

  nativeBuildInputs = [
    invoke
    ipython
    grpcio-tools
    grpclib
    synchronicity
    mypy-protobuf
    ruff
  ]
  ++ synchronicity.optional-dependencies.compile;

  nativeCheckInputs = [
    fastapi
    flaky
    httpx
    mypy
    pyjwt
    pytest-asyncio
    pytest-env
    pytest-markdown-docs
    pytest-timeout
    pytestCheckHook
    python-dotenv
    six
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    cbor2
    certifi
    click
    grpclib
    protobuf
    rich
    synchronicity
    toml
    typer
    types-certifi
    types-toml
    typing-extensions
    watchfiles
  ];

  disabledTestPaths = [
    # Fail due to not finding /bin/bash
    "test/app_composition_test.py"
    "test/cli_shell_test.py"
    "test/cli_test.py"
    "test/container_test.py"
    "test/mounted_files_test.py"

    # Needs unpackaged pythonjsonlogger
    "test/logging_test.py"

    # Matches against error messages of a specific mypy version
    "test/static_types_test.py"

    # Fails due to "Jupyter is migrating its paths to use standard platformdirs"
    "test/notebook_test.py"
  ];

  disabledTests = [
    # Non-deterministic
    "test_queue_blocking_put"
  ];

  pyproject = true;
  pythonImportsCheck = [ "modal" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${finalAttrs.src.name}/py";

  meta = {
    description = "Python client library for Modal (serverless compute provider)";
    homepage = "https://github.com/modal-labs/modal-client";
    changelog = "https://github.com/modal-labs/modal-client/blob/${finalAttrs.src.tag}/py/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Kharacternyk ];
    mainProgram = "modal";
  };
})
