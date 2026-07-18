{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  llm,
  pytest,
  pytest-asyncio,
  pytest-mock,
  pytest-vcr,
  requests,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "llm-lmstudio";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "agustif";
    repo = "llm-lmstudio";
    rev = "v${version}";
    hash = "sha256-dPrkvoVLDIk/JxUhvUUyjMzovH+Q/O13eTdA6qvdKxY=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    httpx
    llm
    requests
  ];

  optional-dependencies = {
    test = [
      pytest
      pytest-asyncio
      pytest-mock
      pytest-vcr
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "llm_lmstudio"
  ];

  meta = {
    description = "Plugin to use local models via LM Studio API with https://llm.datasette.io";
    homepage = "https://github.com/agustif/llm-lmstudio";
    changelog = "https://github.com/agustif/llm-lmstudio/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dwt ];
  };
}
