{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  faker,
  pytest-aiohttp,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiolookin";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ANMalko";
    repo = "aiolookin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G3/lUgV60CMLskUo83TlvLLIfJtu5DEz+94mdVI4OrI=";
  };

  doCheck = false; # all tests are async and no async plugin is configured

  nativeCheckInputs = [
    faker
    pytest-aiohttp
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiolookin" ];

  meta = {
    description = "Python client for interacting with LOOKin devices";
    homepage = "https://github.com/ANMalko/aiolookin";
    changelog = "https://github.com/ANMalko/aiolookin/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
