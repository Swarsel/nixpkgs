{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  requests,
  requests-oauthlib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tellduslive";
  version = "0.10.12";

  src = fetchFromGitHub {
    owner = "molobrakos";
    repo = "tellduslive";
    tag = "v${version}";
    sha256 = "sha256-fWL+VSvoT+dT0jzD8DZEMxzTlqj4TYGCJPLpeui5q64=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    docopt
    requests
    requests-oauthlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "tellduslive" ];

  meta = {
    description = "Python module to communicate with Telldus Live";
    homepage = "https://github.com/molobrakos/tellduslive";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "tellduslive";
  };
}
