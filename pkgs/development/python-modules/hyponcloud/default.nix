{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "hyponcloud";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "jcisio";
    repo = "hyponcloud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Mn+OZHpDSMgA3mUi1s2t+HTlsnsN9eFfzdNNddDz6OA=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "hyponcloud" ];

  meta = {
    description = "Python library for Hypontech Cloud API for solar inverter monitoring";
    homepage = "https://github.com/jcisio/hyponcloud";
    changelog = "https://github.com/jcisio/hyponcloud/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
