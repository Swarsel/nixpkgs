{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "async-lru";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "async-lru";
    tag = "v${version}";
    hash = "sha256-ytmh6tY6AS2VHajCnnRBSi0i57DUu+ikpbil/RwFyYA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    pytest-timeout
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "async_lru" ];

  meta = {
    description = "Simple lru cache for asyncio";
    homepage = "https://github.com/wikibusiness/async_lru";
    changelog = "https://github.com/aio-libs/async-lru/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
