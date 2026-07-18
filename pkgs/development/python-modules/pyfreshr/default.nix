{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyfreshr";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "SierraNL";
    repo = "pyfreshr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YErjzr9etWaETR4mXJaY33LRVXH4KxTErlB0AIOPmNk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyfreshr" ];

  meta = {
    description = "Async Python client for the Fresh-r / bw-log.com API";
    homepage = "https://github.com/SierraNL/pyfreshr";
    changelog = "https://github.com/SierraNL/pyfreshr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
