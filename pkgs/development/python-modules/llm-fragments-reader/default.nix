{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  httpx-sse,
  llm,
  llm-fragments-reader,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-fragments-reader";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-fragments-reader";
    tag = version;
    hash = "sha256-2xdvOpMGsTtnerrlGiVSHoJrM+GQ7Zgv+zn2SAwYAL4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-httpx
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_fragments_reader" ];
  passthru.tests = llm.mkPluginTest llm-fragments-reader;

  meta = {
    description = "Run URLs through the Jina Reader API";
    homepage = "https://github.com/simonw/llm-fragments-reader";
    changelog = "https://github.com/simonw/llm-fragments-reader/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
