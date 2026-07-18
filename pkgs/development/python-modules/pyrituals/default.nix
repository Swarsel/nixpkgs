{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyrituals";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "milanmeu";
    repo = "pyrituals";
    tag = version;
    hash = "sha256-nCyfwOONtpwRLFq3crRacmrWef6J3mOfKz4fvkOcb3g=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyrituals" ];

  meta = {
    description = "Python wrapper for the Rituals Perfume Genie API";
    homepage = "https://github.com/milanmeu/pyrituals";
    changelog = "https://github.com/milanmeu/pyrituals/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
