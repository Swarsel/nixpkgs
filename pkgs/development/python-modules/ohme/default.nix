{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ohme";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "dan-r";
    repo = "ohmepy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MhFDwEu67Gnk9WJCrWKLs3KSk/KryC/QFEpdkZqbgT4=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "ohme" ];

  meta = {
    description = "Module for interacting with the Ohme API";
    homepage = "https://github.com/dan-r/ohmepy";
    changelog = "https://github.com/dan-r/ohmepy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
