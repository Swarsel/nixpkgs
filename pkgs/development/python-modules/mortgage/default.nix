{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mortgage";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "jlumbroso";
    repo = "mortgage";
    tag = "v${version}";
    hash = "sha256-UwSEKfMQqxpcF+7TF/+qD6l8gEO/qDCUklpZz1Nt/Ok=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "mortgage" ];

  meta = {
    description = "Mortgage calculator";
    homepage = "https://github.com/jlumbroso/mortgage";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
