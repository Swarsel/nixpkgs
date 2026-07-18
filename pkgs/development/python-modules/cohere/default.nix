{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  aiohttp,
  buildPythonPackage,
  # dependencies
  fastavro,
  httpx,
  httpx-aiohttp,
  oci,
  # build-system
  poetry-core,
  pydantic,
  pydantic-core,
  requests,
  tokenizers,
  types-requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "cohere";
  version = "7.0.4";

  src = fetchFromGitHub {
    owner = "cohere-ai";
    repo = "cohere-python";
    tag = version;
    hash = "sha256-iFqzWuWOKbJcvmGFEI0jt0fkBlZHlzmzZXZO7tIn638=";
  };

  # tests require CO_API_KEY
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    fastavro
    httpx
    pydantic
    pydantic-core
    requests
    tokenizers
    types-requests
    typing-extensions
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      httpx-aiohttp
    ];

    oci = [ oci ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cohere" ];

  pythonRelaxDeps = [
    "pydantic-core"
  ];

  meta = {
    description = "Simplify interfacing with the Cohere API";
    homepage = "https://docs.cohere.com/docs";
    changelog = "https://github.com/cohere-ai/cohere-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
