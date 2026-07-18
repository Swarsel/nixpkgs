{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pypoint";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "fredrike";
    repo = "pypoint";
    tag = "v${version}";
    hash = "sha256-9z9VcY42uHIksIvDU1Vz+kvXNmrCu08fGB/waQahmyg=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pypoint" ];

  meta = {
    description = "Python module for communicating with Minut Point";
    homepage = "https://github.com/fredrike/pypoint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
