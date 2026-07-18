{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  camel-converter,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "meilisearch";
  version = "0.42.0";

  src = fetchFromGitHub {
    owner = "meilisearch";
    repo = "meilisearch-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MUFUFTYb0/xuTXC5GViWH7LRsmZwhZIjPAbE3+ZajgQ=";
  };

  # Tests spin up a local server and are not mocking the requests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    camel-converter
    requests
  ]
  ++ camel-converter.optional-dependencies.pydantic;

  pyproject = true;
  pythonImportsCheck = [ "meilisearch" ];

  meta = {
    description = "Client for the Meilisearch API";
    homepage = "https://github.com/meilisearch/meilisearch-python";
    changelog = "https://github.com/meilisearch/meilisearch-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
