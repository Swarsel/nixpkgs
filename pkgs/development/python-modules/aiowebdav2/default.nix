{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatchling,
  lxml,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiowebdav2";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jpbede";
    repo = "aiowebdav2";
    tag = "v${version}";
    hash = "sha256-W3TdumweNyGz2qDFgSGu+ZPnEpLvWQQ216jER6e4k18=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
    lxml
    python-dateutil
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiowebdav2" ];

  meta = {
    description = "Async Python 3 client for WebDAV";
    homepage = "https://github.com/jpbede/aiowebdav2";
    changelog = "https://github.com/jpbede/aiowebdav2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
