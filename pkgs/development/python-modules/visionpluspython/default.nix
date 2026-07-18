{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyjwt,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "visionpluspython";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Watts-Digital";
    repo = "visionpluspython";
    tag = finalAttrs.version;
    hash = "sha256-jLn7L9yfyDN+cP5BuQqRQT+krDMLp3OmUOjUpOmFT8U=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "visionpluspython" ];

  meta = {
    description = "Python API wrapper for Watts Vision+ smart home system";
    homepage = "https://github.com/Watts-Digital/visionpluspython";
    changelog = "https://github.com/Watts-Digital/visionpluspython/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
