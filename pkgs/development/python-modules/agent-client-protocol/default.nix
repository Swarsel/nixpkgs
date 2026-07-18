{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  opentelemetry-sdk,
  # build-system
  pdm-backend,
  # dependencies
  pydantic,
  # tests
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "agent-client-protocol";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "python-sdk";
    tag = finalAttrs.version;
    hash = "sha256-iVmNzAx/YlvFXXVPjS1SmjDqGAr9aRDdSW93Nw2ayAY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    pdm-backend
  ];

  dependencies = [
    pydantic
  ];

  disabledTests = [
    # Hangs forever
    "test_spawn_agent_process_roundtrip"
  ];

  optional-dependencies = {
    logfire = [
      # logfire (unpackaged)
      opentelemetry-sdk
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "acp" ];

  meta = {
    description = "Python SDK for ACP clients and agents";
    homepage = "https://github.com/agentclientprotocol/python-sdk";
    changelog = "https://github.com/agentclientprotocol/python-sdk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
