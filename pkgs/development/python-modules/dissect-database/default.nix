{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dissect-database";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.database";
    tag = finalAttrs.version;
    hash = "sha256-z3Ra8BjPGozcx5bF+FKcA/bnsO8F++UBUEQ2tBd+X5Q=";
  };

  # Test files are not ready
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.database" ];

  meta = {
    description = "Dissect module implementing a parser for various database formats";
    homepage = "https://github.com/fox-it/dissect.database";
    changelog = "https://github.com/fox-it/dissect.database/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
