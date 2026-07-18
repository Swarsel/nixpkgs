{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "logging-tree";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "brandon-rhodes";
    repo = "logging_tree";
    tag = finalAttrs.version;
    hash = "sha256-9MeCx708EUe5dmFkol+HISzdBX+yar1HjKIAwmg1msA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "logging_tree" ];

  meta = {
    description = "Debug Python logging problems by printing out the tree of handlers you have defined";
    homepage = "https://github.com/brandon-rhodes/logging_tree";
    license = [ lib.licenses.bsd2 ];
    maintainers = [ lib.maintainers.rskew ];
  };
})
