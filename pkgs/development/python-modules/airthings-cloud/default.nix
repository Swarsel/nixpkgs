{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "airthings-cloud";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyAirthings";
    tag = finalAttrs.version;
    hash = "sha256-8fB8bQ7GHPnNk4lVtP5yZ6ys3J2R+olqSPCPpGquWRk=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "airthings" ];

  meta = {
    description = "Python module for Airthings";
    homepage = "https://github.com/Danielhiversen/pyAirthings";
    changelog = "https://github.com/Danielhiversen/pyAirthings/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
