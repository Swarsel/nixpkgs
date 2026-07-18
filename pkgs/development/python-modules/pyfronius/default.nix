{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiounittest,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyfronius";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "nielstron";
    repo = "pyfronius";
    tag = version;
    hash = "sha256-KUO5e3UYIm49kgBxidizt77AplojOv4UsnIoDa0Gtv4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyfronius" ];

  meta = {
    description = "Python module to communicate with Fronius Symo";
    homepage = "https://github.com/nielstron/pyfronius";
    changelog = "https://github.com/nielstron/pyfronius/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
