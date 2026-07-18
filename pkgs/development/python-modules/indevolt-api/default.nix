{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "indevolt-api";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "Xirt";
    repo = "indevolt-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KFYavUYlFNaHj3QqJsHqhn7s1KzYAPjJrR6h7lw+ttU=";
  };

  # no tests in upstream repository
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "indevolt_api" ];

  meta = {
    description = "Python API client for Indevolt devices";
    homepage = "https://github.com/Xirt/indevolt-api";
    changelog = "https://github.com/Xirt/indevolt-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
