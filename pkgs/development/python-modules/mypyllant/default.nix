{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # tests
  aioresponses,
  buildPythonPackage,
  country-list,
  freezegun,
  # build-system
  hatch-vcs,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  requests,
}:

buildPythonPackage rec {
  pname = "mypyllant";
  version = "0.9.16";

  src = fetchFromGitHub {
    owner = "signalkraft";
    repo = "myPyllant";
    tag = "v${version}";
    hash = "sha256-Uzy7W+ZwdBDKKayl0z6FIj/NK9uA/IsWFFJCeO0o4vQ=";
  };

  nativeCheckInputs = [
    aioresponses
    country-list
    freezegun
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytest-xdist
    pytestCheckHook
    pyyaml
    requests
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    aiohttp
    pydantic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "myPyllant"
  ];

  meta = {
    description = "Python library to interact with the API behind the myVAILLANT app";
    homepage = "https://github.com/signalkraft/myPyllant";
    changelog = "https://github.com/signalkraft/myPyllant/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ urbas ];
  };
}
