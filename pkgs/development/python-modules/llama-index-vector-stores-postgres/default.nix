{
  lib,
  asyncpg,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  pgvector,
  psycopg2,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-vector-stores-postgres";
  version = "0.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-4/cvFvCod2thC0RiW1/KtVpZd84vpafTsWIwahDZtOg=";
    pname = "llama_index_vector_stores_postgres";
  };

  build-system = [ hatchling ];

  dependencies = [
    asyncpg
    llama-index-core
    pgvector
    psycopg2
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.vector_stores.postgres" ];
  pythonRelaxDeps = [ "pgvector" ];
  pythonRemoveDeps = [ "psycopg2-binary" ];

  meta = {
    description = "LlamaIndex Vector Store Integration for Postgres";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/vector_stores/llama-index-vector-stores-postgres";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
