{
  lib,
  aiohttp,
  aiohttp-sse-client,
  buildPythonPackage,
  charset-normalizer,
  dataclasses-json,
  fetchPypi,
  oauth2-client,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "home-connect-async";
  version = "0.8.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4iF63TqmT47nHGJd9H4D6SnzclToj5S5Z/pm4YxbvQA=";
    pname = "home_connect_async";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    aiohttp
    aiohttp-sse-client
    charset-normalizer
    dataclasses-json
    oauth2-client
  ];

  pyproject = true;

  pythonImportsCheck = [
    "home_connect_async"
  ];

  meta = {
    description = "Async SDK for BSH Home Connect API";
    homepage = "https://pypi.org/project/home-connect-async";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kranzes ];
  };
}
