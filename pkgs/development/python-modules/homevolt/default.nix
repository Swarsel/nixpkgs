{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "homevolt";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyHomevolt";
    tag = finalAttrs.version;
    hash = "sha256-Z+3JwACbdFVivWbhlxO73m1rjyGS+Vc/Y3QICqEY9O0=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "homevolt" ];

  meta = {
    description = "Python library for Homevolt EMS devices";
    homepage = "https://github.com/Danielhiversen/pyHomevolt";
    changelog = "https://github.com/Danielhiversen/pyHomevolt/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
