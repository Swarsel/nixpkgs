{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioairzone";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "Noltari";
    repo = "aioairzone";
    tag = finalAttrs.version;
    hash = "sha256-mYCArILj+B4eXdmK8hPAQP2/QYwDoZcYGGhy3p+VABQ=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aioairzone" ];

  meta = {
    description = "Module to control AirZone devices";
    homepage = "https://github.com/Noltari/aioairzone";
    changelog = "https://github.com/Noltari/aioairzone/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
