{
  lib,
  buildPythonPackage,
  docling,
  docling-core,
  fetchPypi,
  hatchling,
  llama-index-core,
  numpy,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-docling";
  version = "0.4.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-mOZtVcvbWkri9SZeWAfGxjgKS9J8uF3sk/O/ydQgj+s=";
    pname = "llama_index_readers_docling";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    docling
    docling-core
    llama-index-core
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.docling" ];

  meta = {
    description = "Llama-index readers docling integration";
    homepage = "https://pypi.org/project/llama-index-readers-docling/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
