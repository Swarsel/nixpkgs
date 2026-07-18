{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  construct,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "construct-classes";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "matejcik";
    repo = "construct-classes";
    tag = "v${version}";
    hash = "sha256-xRYf6Tg4XyQN+g8uOaws46KKb0abD/M/5Q+SlnzEp/8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ construct ];
  pyproject = true;
  pythonImportsCheck = [ "construct_classes" ];

  meta = {
    description = "Parse your binary data into dataclasses";
    homepage = "https://github.com/matejcik/construct-classes";
    changelog = "https://github.com/matejcik/construct-classes/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
