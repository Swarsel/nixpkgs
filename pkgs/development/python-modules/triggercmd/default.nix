{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyjwt,
  requests,
  setuptools,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "triggercmd";
  version = "0.0.36";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ky6U0iAoxQMewh+gB7gBG61PuxUnOONe92io6iygGQU=";
  };

  # Tests require network access and authentication tokens
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    websocket-client
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "triggercmd" ];

  meta = {
    description = "Python agent for TRIGGERcmd cloud service";
    homepage = "https://github.com/rvmey/triggercmd-python-agent";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
