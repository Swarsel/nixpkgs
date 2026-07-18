{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  pyowm,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-weather";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bqvt09YSRD8BQfZjwnMlsO5oSscjh+piQXbUUZGeXbs=";
    pname = "llama_index_readers_weather";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    pyowm
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.weather" ];

  meta = {
    description = "LlamaIndex Readers Integration for Weather";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-weather";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
