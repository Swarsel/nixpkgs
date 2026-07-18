{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # requirements
  editdistpy,
  importlib-resources,
  # for testing
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "symspellpy";
  version = "6.9.0";

  src = fetchFromGitHub {
    owner = "mammothb";
    repo = "symspellpy";
    tag = "v${version}";
    hash = "sha256-isxANYSiwN8pQ7/XfMtO7cyoGdTyrXYOZ6C5rDJsJIs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
    importlib-resources
  ];

  build-system = [ setuptools ];
  dependencies = [ editdistpy ];
  pyproject = true;

  pythonImportsCheck = [
    "symspellpy"
    "symspellpy.symspellpy"
  ];

  meta = {
    description = "Python port of SymSpell v6.7.1, which provides much higher speed and lower memory consumption";
    homepage = "https://github.com/mammothb/symspellpy";
    changelog = "https://github.com/mammothb/symspellpy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
