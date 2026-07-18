{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "webmin-xmlrpc";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "autinerd";
    repo = "webmin-xmlrpc";
    tag = version;
    hash = "sha256-qCS5YV3o7ozO7fDaJucQvU0dEyTbxTivtTDKQVY4pkM=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "webmin_xmlrpc" ];

  meta = {
    description = "Python interface to interact with the Webmin XML-RPC API";
    homepage = "https://github.com/autinerd/webmin-xmlrpc";
    changelog = "https://github.com/autinerd/webmin-xmlrpc/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
