{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  urllib3,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "asusrouter";
  version = "1.21.3";

  src = fetchFromGitHub {
    owner = "Vaskivskyi";
    repo = "asusrouter";
    tag = version;
    hash = "sha256-7OmuJ3VKBdg5hK8RAkA8DQGd4L+g9S17VT0B5JhNaSA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==80.9.0" "setuptools"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    urllib3
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "asusrouter" ];

  meta = {
    description = "API wrapper for communication with ASUSWRT-powered routers using HTTP protocol";
    homepage = "https://github.com/Vaskivskyi/asusrouter";
    changelog = "https://github.com/Vaskivskyi/asusrouter/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
