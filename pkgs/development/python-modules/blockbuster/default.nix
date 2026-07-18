{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  forbiddenfruit,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "blockbuster";
  version = "1.5.25";

  src = fetchFromGitHub {
    owner = "cbornet";
    repo = "blockbuster";
    tag = "v${version}";
    hash = "sha256-1+Q1IdJXqLAy7kIcVU38TC3dtMeWAn7YOLyGrjCkxD0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    requests
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];
  dependencies = [ forbiddenfruit ];

  disabledTests = [
    # network access
    "test_ssl_socket"
  ];

  pyproject = true;
  pythonImportsCheck = [ "blockbuster" ];

  meta = {
    description = "Utility to detect blocking calls in the async event loop";
    homepage = "https://github.com/cbornet/blockbuster";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
