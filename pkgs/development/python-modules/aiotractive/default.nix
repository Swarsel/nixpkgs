{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  orjson,
  setuptools,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiotractive";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "zhulik";
    repo = "aiotractive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wRV/ZQ2T3Dlrmq6jY5IatrGr07uxPFWcVoMiJN+md88=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiotractive" ];
  pythonRelaxDeps = [ "orjson" ];

  meta = {
    description = "Python client for the Tractive REST API";
    homepage = "https://github.com/zhulik/aiotractive";
    changelog = "https://github.com/zhulik/aiotractive/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
