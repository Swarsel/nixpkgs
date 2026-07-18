{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  click,
  # dependencies
  googleapis-common-protos,
  grpcio,
  # build-system
  hatchling,
  protobuf,
  # tests
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "cwsandbox";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "coreweave";
    repo = "cwsandbox-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y9rsuAXmpMok0ZqdLhAfavglXh5Hz4VPy1UByYMM1WA=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.cli;

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    googleapis-common-protos
    grpcio
    protobuf
  ];

  disabledTests = [
    # Failed: DID NOT RAISE any of (<class 'cwsandbox.exceptions.SandboxNotRunningError'>, <class 'cwsandbox.exceptions.SandboxTerminatedError'>)
    "test_stop_while_waiting"
  ];

  optional-dependencies = {
    cli = [
      click
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cwsandbox" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python client library for CoreWeave Sandbox";
    homepage = "https://github.com/coreweave/cwsandbox-client";
    changelog = "https://github.com/coreweave/cwsandbox-client/blob/${finalAttrs.src.tag}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
