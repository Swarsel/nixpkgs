{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aladdin-connect";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "shoejosh";
    repo = "aladdin-connect";
    tag = finalAttrs.version;
    hash = "sha256-kLvMpSGa5WyDOH3ejAJyFGsB9IiMXp+nvVxM/ZkxyFw=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "aladdin_connect" ];

  meta = {
    description = "Python library for interacting with Genie Aladdin Connect devices";
    homepage = "https://github.com/shoejosh/aladdin-connect";
    changelog = "https://github.com/shoejosh/aladdin-connect/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
