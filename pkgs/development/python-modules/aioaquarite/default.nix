{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  google-auth,
  google-cloud-firestore,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioaquarite";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "fdebrus";
    repo = "aioaquarite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pf/a0W1Ix/3Cd6dMUvHqb6DwT56PvtSf/GpicrL8y1A=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    google-auth
    google-cloud-firestore
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioaquarite" ];

  meta = {
    description = "Async Python client for the Hayward Aquarite pool API";
    homepage = "https://github.com/fdebrus/aioaquarite";
    changelog = "https://github.com/fdebrus/aioaquarite/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
