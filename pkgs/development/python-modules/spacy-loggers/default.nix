{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  spacy,
  spacy-loggers,
  # dependencies
  wandb,
  wasabi,
}:

buildPythonPackage (finalAttrs: {
  pname = "spacy-loggers";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "spacy-loggers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Kl8FSs+sbIF2Ml5AJhP5aY7lWnDLqUr7QBAq+63SW5Q=";
  };

  # skipping the checks, because it requires a cycle dependency to spacy as well.
  doCheck = false;

  nativeCheckInputs = [
    spacy
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    wandb
    wasabi
  ];

  pyproject = true;
  pythonImportsCheck = [ "spacy_loggers" ];

  passthru = {
    tests.pytest = spacy-loggers.overridePythonAttrs {
      doCheck = true;
    };
  };

  meta = {
    description = "Logging utilities for spaCy";
    homepage = "https://github.com/explosion/spacy-loggers";
    changelog = "https://github.com/explosion/spacy-loggers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stunkymonkey ];
  };
})
