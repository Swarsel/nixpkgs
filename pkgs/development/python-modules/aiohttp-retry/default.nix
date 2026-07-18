{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-retry";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "inyutin";
    repo = "aiohttp_retry";
    tag = "v${version}";
    hash = "sha256-8S4gjeN8ktdDNd8GUsejaZdCaG/VXYPo0RJpwrrttGQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'version="2.9.0"' 'version="${version}"'
  '';

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "aiohttp_retry" ];

  meta = {
    description = "Retry client for aiohttp";
    homepage = "https://github.com/inyutin/aiohttp_retry";
    changelog = "https://github.com/inyutin/aiohttp_retry/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
