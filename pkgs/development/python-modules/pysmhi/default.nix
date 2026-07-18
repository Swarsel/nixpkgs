{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  freezegun,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pysmhi";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "gjohansson-ST";
    repo = "pysmhi";
    tag = "v${version}";
    hash = "sha256-9t/mhmQfNwuX2QVS1OOeKZOARXK9otjGtwJEfVeizPU=";
  };

  nativeCheckInputs = [
    aresponses
    freezegun
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysmhi" ];

  meta = {
    description = "Retrieve open data from SMHI api";
    homepage = "https://github.com/gjohansson-ST/pysmhi";
    changelog = "https://github.com/gjohansson-ST/pysmhi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
