{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fastembed,
  grpcio,
  grpcio-tools,
  httpx,
  numpy,
  poetry-core,
  portalocker,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  urllib3,
}:

buildPythonPackage rec {
  pname = "qdrant-client";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "qdrant";
    repo = "qdrant-client";
    tag = "v${version}";
    hash = "sha256-ZBP1D67u+KZmBi614nuToauI+xhdH1PKD3g6xRfFQxk=";
  };

  # Tests require network access
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ poetry-core ];

  dependencies = [
    grpcio
    grpcio-tools
    httpx
    numpy
    portalocker
    pydantic
    urllib3
  ]
  ++ httpx.optional-dependencies.http2;

  optional-dependencies = {
    fastembed = [ fastembed ];
  };

  pyproject = true;
  pythonImportsCheck = [ "qdrant_client" ];

  pythonRelaxDeps = [
    "portalocker"
  ];

  meta = {
    description = "Python client for Qdrant vector search engine";
    homepage = "https://github.com/qdrant/qdrant-client";
    changelog = "https://github.com/qdrant/qdrant-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
