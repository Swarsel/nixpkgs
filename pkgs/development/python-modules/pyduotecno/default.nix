{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyduotecno";
  version = "2024.10.1";

  src = fetchFromGitHub {
    owner = "Cereal2nd";
    repo = "pyDuotecno";
    tag = version;
    hash = "sha256-I/ZA2ooa6nunUr/4K+FWAGMOdcJDfGzE99jJ8zTe2Po=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "duotecno" ];

  meta = {
    description = "Module to interact with Duotecno IP interfaces";
    homepage = "https://github.com/Cereal2nd/pyDuotecno";
    changelog = "https://github.com/Cereal2nd/pyDuotecno/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
