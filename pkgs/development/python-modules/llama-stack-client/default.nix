{
  lib,
  aiohttp,
  anyio,
  buildPythonPackage,
  click,
  dirty-equals,
  distro,
  fetchPypi,
  fire,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  httpx-aiohttp,
  nest-asyncio,
  openai,
  pandas,
  prompt-toolkit,
  pyaml,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  requests,
  respx,
  rich,
  sniffio,
  termcolor,
  tqdm,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-stack-client";
  version = "0.7.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-SxPWXuH1ob5eYoZyWWs2YWsyElJufS28QXnby2hgwWc=";
    pname = "llama_stack_client";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" "hatchling"
  '';

  nativeCheckInputs = [
    dirty-equals
    nest-asyncio
    openai
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    respx
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    anyio
    click
    distro
    fire
    httpx
    pandas
    prompt-toolkit
    pyaml
    pydantic
    requests
    rich
    sniffio
    termcolor
    tqdm
    typing-extensions
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/api_resources/"
    "tests/test_client.py"
    "tests/integration/test_agent_turn_step_events.py"

    # AttributeError: 'Agent' object has no attribute '_session_last_response_id'
    "tests/lib/agents/test_agent_responses.py::test_agent_tracks_multiple_sessions"
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      httpx-aiohttp
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "llama_stack_client" ];

  meta = {
    description = "Library for the llama-stack-client API";
    homepage = "https://github.com/llamastack/llama-stack-client-python";
    changelog = "https://github.com/llamastack/llama-stack-client-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
