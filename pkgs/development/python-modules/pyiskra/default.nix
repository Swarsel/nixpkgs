{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pymodbus,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyiskra";
  version = "0.1.29";

  src = fetchFromGitHub {
    owner = "Iskramis";
    repo = "pyiskra";
    tag = "v${version}";
    hash = "sha256-aDS9chlbSvcZL4LaE5P+JXxREhlqLjOnlqIYc8yagkQ=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pymodbus
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyiskra" ];

  meta = {
    description = "Python Iskra devices interface";
    homepage = "https://github.com/Iskramis/pyiskra";
    changelog = "https://github.com/Iskramis/pyiskra/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
