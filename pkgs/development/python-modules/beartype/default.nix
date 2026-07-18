{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "beartype";
  version = "0.22.9";

  src = fetchFromGitHub {
    owner = "beartype";
    repo = "beartype";
    tag = "v${version}";
    hash = "sha256-F9x2qvzll1nUcTQZjaky+0ukP1RXoW35crzfS/pmvTs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    typing-extensions
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "beartype" ];

  meta = {
    description = "Fast runtime type checking for Python";
    homepage = "https://github.com/beartype/beartype";
    changelog = "https://github.com/beartype/beartype/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
