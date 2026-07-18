{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # deps
  httpcore,
  httpx,
  openai,
  # build
  poetry-core,
  pydantic,
  # tests
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-dotenv,
  requests,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "exa-py";
  version = "2.16.1";

  # pypi doesn't include tests but there aren't any upstream git tags
  src = fetchFromGitHub {
    owner = "exa-labs";
    repo = "exa-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zMQAPJnIHA7PiHCoPf0/iPrTEsctnM8cQBY2fVpDpjo=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    httpcore
    httpx
    openai
    pydantic
    python-dotenv
    requests
    typing-extensions
  ];

  pyproject = true;
  pytestFlags = [ "tests/" ];

  pythonImportsCheck = [
    "exa_py"
  ];

  meta = {
    description = "Official Python SDK for Exa, the web search API for AI";
    homepage = "https://github.com/exa-labs/exa-py/";
    changelog = "https://github.com/exa-labs/exa-py/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
})
