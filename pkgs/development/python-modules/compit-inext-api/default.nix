{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "compit-inext-api";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Przemko92";
    repo = "compit-inext-api";
    tag = finalAttrs.version;
    hash = "sha256-Me3bVTz9kZcuPgFM3/SZlcvw8LgqxQnXuLfY5lLhUeU=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "compit_inext_api" ];

  meta = {
    description = "Python client for the Compit iNext API";
    homepage = "https://github.com/Przemko92/compit-inext-api";
    changelog = "https://github.com/Przemko92/compit-inext-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
