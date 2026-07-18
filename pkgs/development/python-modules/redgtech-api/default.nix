{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "redgtech-api";
  version = "0.1.38";

  src = fetchFromGitHub {
    owner = "redgtech-automacao";
    repo = "redgtech-python-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-28hA0ay4oBNiJAsLPuEv7hP/V76Q/+MdwBwvAlNpO1k=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "redgtech_api" ];

  meta = {
    description = "Python package to interact with the Redgtech API";
    homepage = "https://github.com/redgtech-automacao/redgtech-python-api";
    changelog = "https://github.com/redgtech-automacao/redgtech-python-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
