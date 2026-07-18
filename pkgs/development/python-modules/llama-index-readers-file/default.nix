{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  defusedxml,
  fetchPypi,
  hatchling,
  llama-index-core,
  pymupdf,
  pypdf,
  striprtf,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-file";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/zZtb/XstxGSdayFkxDYtnLYtrMmGvrgL0CE/OkHa9A=";
    pname = "llama_index_readers_file";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    beautifulsoup4
    defusedxml
    llama-index-core
    pymupdf
    pypdf
    striprtf
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.file" ];

  pythonRelaxDeps = [
    "pymupdf"
    "pypdf"
    "striprtf"
    "pandas"
  ];

  meta = {
    description = "LlamaIndex Readers Integration for files";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-file";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
