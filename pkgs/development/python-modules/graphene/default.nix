{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  graphql-core,
  graphql-relay,
  pytest-asyncio,
  pytest-benchmark,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "graphene";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "graphql-python";
    repo = "graphene";
    tag = "v${version}";
    hash = "sha256-K1IGKK3nTsRBe2D/cKJ/ahnAO5xxjf4gtollzTwt1zU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-benchmark
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    graphql-core
    graphql-relay
    python-dateutil
    typing-extensions
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "graphene" ];

  meta = {
    description = "GraphQL Framework for Python";
    homepage = "https://github.com/graphql-python/graphene";
    changelog = "https://github.com/graphql-python/graphene/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
