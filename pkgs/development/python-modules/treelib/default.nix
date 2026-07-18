{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "treelib";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "caesar0301";
    repo = "treelib";
    tag = "v${version}";
    hash = "sha256-jvaZVy+FUcCcIdvWK6zFL8IBVH+hMiPMmv5shFXLo0k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "treelib" ];

  meta = {
    description = "Efficient implementation of tree data structure in python 2/3";
    homepage = "https://github.com/caesar0301/treelib";
    changelog = "https://github.com/caesar0301/treelib/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
