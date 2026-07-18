{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  lxml,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymeteoclimatic";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "adrianmo";
    repo = "pymeteoclimatic";
    tag = finalAttrs.version;
    hash = "sha256-Yln+uUwnb5mlPS3uRRzpAH6kSc9hU2jEnhk/3ifiwWI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "meteoclimatic" ];

  meta = {
    description = "Python wrapper around the Meteoclimatic service";
    homepage = "https://github.com/adrianmo/pymeteoclimatic";
    changelog = "https://github.com/adrianmo/pymeteoclimatic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
