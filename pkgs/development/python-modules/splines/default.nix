{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  setuptools,
}:

buildPythonPackage {
  pname = "splines";
  version = "0.3.3";

  src = fetchPypi {
    hash = "sha256-nZEIMD8POw4b6OAUxKckxnSmwFWKsQHhTdBMdFBcTrk=";
    pname = "splines";
    version = "0.3.3";
  };

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "splines" ];

  meta = {
    description = "Spline curves in Euclidean and rotation spaces";
    homepage = "https://github.com/AudioSceneDescriptionFormat/splines";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ BatteredBunny ];
  };
}
