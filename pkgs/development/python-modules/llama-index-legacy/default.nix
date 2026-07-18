{
  lib,
  buildPythonPackage,
  fetchPypi,
  llama-index-core,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "llama-index-legacy";
  version = "0.9.48.post4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+Kl2Tn4TSlK/715T0tYlYb/AH8CYdMUcwAHfb1MCrjA=";
    pname = "llama_index_legacy";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ llama-index-core ];
  pyproject = true;
  pythonRelaxDeps = [ "tenacity" ];

  meta = {
    description = "LlamaIndex Readers Integration for files";
    homepage = "https://github.com/run-llama/llama_index/tree/v0.9.48";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
