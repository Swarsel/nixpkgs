{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sentence-stream";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "sentence-stream";
    tag = "v${version}";
    hash = "sha256-UVoRto2zGf+GZFcYt4NC63Fm9iS7DWgwH7sJrrHxvXs=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    regex
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sentence_stream"
  ];

  meta = {
    description = "Small sentence splitter for text streams";
    homepage = "https://github.com/OHF-Voice/sentence-stream";
    changelog = "https://github.com/OHF-Voice/sentence-stream/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
