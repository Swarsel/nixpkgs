{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # runtime
  httpx,
  pydantic,
  requests,
  # build system
  setuptools,
  setuptools-scm,
  tenacity,
  types-requests,
}:

buildPythonPackage rec {
  pname = "retryhttp";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "austind";
    repo = "retryhttp";
    tag = "release/v${version}";
    hash = "sha256-wUz5cC8O//TqlalDoF1KtUCqONnfCShFv3hU4k4fzuM=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    httpx
    pydantic
    requests
    tenacity
    types-requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "retryhttp" ];

  meta = {
    description = "Retry potentially transient HTTP errors in Python";
    homepage = "https://github.com/austind/retryhttp";
    changelog = "https://github.com/austind/retryhttp/releases/tag/release%2Fv${version}";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ taranarmo ];
  };
}
