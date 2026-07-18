{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  django,
  djangorestframework,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "nested-multipart-parser";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "remigermain";
    repo = "nested-multipart-parser";
    tag = "v${version}";
    hash = "sha256-FFALem8Y43tKL32VSZE1pIlOKEPh5Ryzbu509Xjd+VY=";
  };

  nativeCheckInputs = [
    django
    djangorestframework
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "nested_multipart_parser"
  ];

  meta = {
    description = "Parser for nested data for 'multipart/form'";
    homepage = "https://github.com/remigermain/nested-multipart-parser";
    changelog = "https://github.com/remigermain/nested-multipart-parser/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
