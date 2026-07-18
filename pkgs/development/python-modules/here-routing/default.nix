{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  async-timeout,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "here-routing";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "eifinger";
    repo = "here_routing";
    tag = "v${version}";
    hash = "sha256-h3y5hjaSHH6oIfSt5JTt1+pH7mFLOFiq1RuMZ1uYtTE=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    async-timeout
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "here_routing" ];

  meta = {
    description = "Asynchronous Python client for the HERE Routing V8 API";
    homepage = "https://github.com/eifinger/here_routing";
    changelog = "https://github.com/eifinger/here_routing/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
