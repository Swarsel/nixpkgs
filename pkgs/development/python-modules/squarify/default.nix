{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "squarify";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "laserson";
    repo = "squarify";
    tag = "v${version}";
    hash = "sha256-zSv+6xT9H4WyShRnwjjcNMjY19AFlQ6bw9Mh9p2rL08=";
  };

  propagatedBuildInputs = [ matplotlib ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "squarify" ];

  meta = {
    description = "Pure Python implementation of the squarify treemap layout algorithm";
    homepage = "https://github.com/laserson/squarify";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
