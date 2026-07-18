{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stickytape";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "stickytape";
    tag = version;
    hash = "sha256-KOZN9oxPb91l8QVU07I49UMNXqox8j+oekA1fMtj6l8=";
  };

  # Tests have additional requirements
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "stickytape" ];

  meta = {
    description = "Python module to convert Python packages into a single script";
    homepage = "https://github.com/mwilliamson/stickytape";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "stickytape";
  };
}
