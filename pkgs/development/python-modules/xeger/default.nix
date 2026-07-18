{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "xeger";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "crdoconnor";
    repo = "xeger";
    tag = version;
    hash = "sha256-XujytGzBwJ59C5VihuFUJUxqhyjOIU4sI60hXUqLQvM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xeger" ];

  meta = {
    description = "Library to generate random strings from regular expressions";
    homepage = "https://github.com/crdoconnor/xeger";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
