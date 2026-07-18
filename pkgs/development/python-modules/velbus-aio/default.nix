{
  lib,
  fetchFromGitHub,
  aiofile,
  backoff,
  beautifulsoup4,
  buildPythonPackage,
  lxml,
  pytest-asyncio,
  pytestCheckHook,
  serialx,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "velbus-aio";
  version = "2026.4.1";

  src = fetchFromGitHub {
    owner = "Cereal2nd";
    repo = "velbus-aio";
    tag = finalAttrs.version;
    hash = "sha256-l77L2JI2jXw+cQw/yO1LvyWBxvUF0IBctM5V02BGtO8=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofile
    backoff
    beautifulsoup4
    lxml
    serialx
  ];

  pyproject = true;
  pythonImportsCheck = [ "velbusaio" ];

  meta = {
    description = "Python library to support the Velbus home automation system";
    homepage = "https://github.com/Cereal2nd/velbus-aio";
    changelog = "https://github.com/Cereal2nd/velbus-aio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
