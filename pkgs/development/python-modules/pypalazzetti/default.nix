{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pypalazzetti";
  version = "0.1.20";

  src = fetchFromGitHub {
    owner = "dotvav";
    repo = "py-palazzetti-api";
    tag = "v${version}";
    hash = "sha256-jDsDa/5QFi4HUSagFHG73+Aj5BPOC8UNO+k7XxLZawk=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pypalazzetti" ];

  meta = {
    description = "Library to access and control a Palazzetti stove through a Connection Box";
    homepage = "https://github.com/dotvav/py-palazzetti-api";
    changelog = "https://github.com/dotvav/py-palazzetti-api/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
