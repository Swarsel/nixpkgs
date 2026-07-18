{
  lib,
  aiohttp,
  buildPythonPackage,
  elastic-transport,
  fetchPypi,
  hatchling,
  orjson,
  pyarrow,
  python-dateutil,
  requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "elasticsearch";
  version = "8.18.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mYA18XqMH7p64msYPcp5fc+V24baan7LpW0xr8QPB8c=";
  };

  # Check is disabled because running them destroy the content of the local cluster!
  # https://github.com/elasticsearch/elasticsearch-py/tree/master/test_elasticsearch
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    elastic-transport
    python-dateutil
    typing-extensions
  ];

  optional-dependencies = {
    async = [ aiohttp ];
    orjson = [ orjson ];
    pyarrow = [ pyarrow ];
    requests = [ requests ];
  };

  pyproject = true;
  pythonImportsCheck = [ "elasticsearch" ];

  meta = {
    description = "Official low-level client for Elasticsearch";
    homepage = "https://github.com/elasticsearch/elasticsearch-py";
    changelog = "https://github.com/elastic/elasticsearch-py/releases/tag/v${version}";
    license = lib.licenses.asl20;
  };
}
