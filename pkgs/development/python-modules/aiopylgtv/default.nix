{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  setuptools,
  sqlitedict,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiopylgtv";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "bendavid";
    repo = "aiopylgtv";
    tag = finalAttrs.version;
    hash = "sha256-NkWJGy5QUrhpbARoscrXy/ilCjAz01YxeVTH0I+IjNM=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    sqlitedict
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiopylgtv" ];

  meta = {
    description = "Python library to control webOS based LG TV units";
    homepage = "https://github.com/bendavid/aiopylgtv";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aiopylgtvcommand";
  };
})
