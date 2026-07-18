{
  lib,
  fetchFromGitLab,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  tenacity,
}:

buildPythonPackage rec {
  pname = "doorbirdpy";
  version = "3.0.12";

  src = fetchFromGitLab {
    owner = "klikini";
    repo = "doorbirdpy";
    tag = version;
    hash = "sha256-yJPORXU7hQ3TqSFZzyneQT4aAdrXqPmxnOwFQ665Vus=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    tenacity
  ];

  pyproject = true;
  pythonImportsCheck = [ "doorbirdpy" ];

  meta = {
    description = "Python wrapper for the DoorBird LAN API";
    homepage = "https://gitlab.com/klikini/doorbirdpy";
    changelog = "https://gitlab.com/klikini/doorbirdpy/-/tags/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
