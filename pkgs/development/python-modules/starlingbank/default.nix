{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "starlingbank";
  version = "3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pqWnRyCAc50KQmbqYq9Mje+PWXCFmTAjs8jA13YM0nA=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "starlingbank" ];

  meta = {
    description = "An unofficial python package that provides access to parts of the Starling bank API";
    homepage = "https://github.com/Dullage/starlingbank";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
