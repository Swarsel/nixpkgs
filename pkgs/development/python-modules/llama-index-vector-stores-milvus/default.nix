{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  pymilvus,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-vector-stores-milvus";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-xoelq9/IEFJ541Vs22i6dg6MWxLyV2EChs6OQHPhMJw=";
    pname = "llama_index_vector_stores_milvus";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    pymilvus
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.vector_stores.milvus" ];

  meta = {
    description = "Llama-index vector_stores milvus integration";
    homepage = "https://pypi.org/project/llama-index-vector-stores-milvus/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
