{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nltk,
  nltk-data,
  numpy,
  pint,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "ingredient-parser-nlp";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "strangetom";
    repo = "ingredient-parser";
    tag = version;
    hash = "sha256-WodKuK4CaBipKxLQyOgQ0sFfTDzS/F0URgkoQaFNoNc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Needed for tests
  preCheck = ''
    export NLTK_DATA=${nltk-data.averaged-perceptron-tagger-eng}
  '';

  build-system = [ setuptools ];

  dependencies = [
    nltk
    numpy
    pint
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ingredient_parser"
  ];

  meta = {
    description = "Parse structured information from recipe ingredient sentences";
    homepage = "https://github.com/strangetom/ingredient-parser/";
    changelog = "https://github.com/strangetom/ingredient-parser/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ antonmosich ];
  };
}
