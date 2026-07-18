{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  flit-core,
  pytest-aiohttp,
  pytest-cov-stub,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "aiohttp-remotes";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp-remotes";
    tag = "v${version}";
    hash = "sha256-/bcYrpZfO/sXc0Tcpr67GBqCu4ZSAVmUj9kzupIHHnM=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    flit-core
  ];

  dependencies = [
    aiohttp
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_remotes" ];

  meta = {
    description = "Set of useful tools for aiohttp.web server";
    homepage = "https://github.com/wikibusiness/aiohttp-remotes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qyliss ];
  };
}
