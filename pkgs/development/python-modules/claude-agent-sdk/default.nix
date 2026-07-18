{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  hatchling,
  mcp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  sniffio,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "claude-agent-sdk";
  version = "0.2.110";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-agent-sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tz26ueGAMFM7sD95FoAzhKHvNo7NV9fYZoKfJy/t8Lw=";
  };

  nativeCheckInputs = [
    anyio
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ]
  ++ anyio.passthru.optional-dependencies.trio;

  build-system = [ hatchling ];

  dependencies = [
    anyio
    mcp
    sniffio
    typing-extensions
  ];

  disabledTests = [
    # Code not available
    "test_query_with_async_iterable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "claude_agent_sdk" ];

  meta = {
    description = "Python SDK for Claude Agent";
    homepage = "https://github.com/anthropics/claude-agent-sdk-python";
    changelog = "https://github.com/anthropics/claude-agent-sdk-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
