{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vincenty";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "maurycyp";
    repo = "vincenty";
    tag = finalAttrs.version;
    hash = "sha256-gzdaAtRjkhn0N/Dmk1tZc2GKRp1eveVbX+2G9cF+KNI=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "vincenty" ];

  meta = {
    description = "Calculate the geographical distance between 2 points with extreme accuracy";
    homepage = "https://github.com/maurycyp/vincenty";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
