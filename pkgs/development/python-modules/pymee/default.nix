{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  regex,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymee";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "FreshlyBrewedCode";
    repo = "pymee";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VNKIA/1juhkn11nkW52htvE4daXJoySeEyevWbboUek=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    websockets
    regex
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymee" ];

  meta = {
    description = "Python library to interact with homee";
    homepage = "https://github.com/FreshlyBrewedCode/pymee";
    changelog = "https://github.com/FreshlyBrewedCode/pymee/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
