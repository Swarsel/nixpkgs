{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "typing-validation";
  version = "1.2.12";

  src = fetchFromGitHub {
    owner = "hashberg-io";
    repo = "typing-validation";
    tag = "v${version}";
    hash = "sha256-N0VAxlxB96NA01c/y4xtoLKoiqAxfhJJV0y/3w6H9ek=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
  ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "typing_validation" ];

  meta = {
    description = "Simple library for runtime type-checking";
    homepage = "https://github.com/hashberg-io/typing-validation";
    changelog = "https://github.com/hashberg-io/typing-validation/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
