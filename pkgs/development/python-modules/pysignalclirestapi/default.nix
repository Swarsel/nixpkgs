{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pysignalclirestapi";
  version = "0.3.24";

  src = fetchFromGitHub {
    owner = "bbernhard";
    repo = "pysignalclirestapi";
    tag = version;
    hash = "sha256-LGP/Oo4FCvOq3LuUZRYFkK2JV1kEu3MeCDgnYo+91o4=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    requests
    six
  ];

  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pysignalclirestapi" ];

  meta = {
    description = "Small python library for the Signal Cli REST API";
    homepage = "https://github.com/bbernhard/pysignalclirestapi";
    changelog = "https://github.com/bbernhard/pysignalclirestapi/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
