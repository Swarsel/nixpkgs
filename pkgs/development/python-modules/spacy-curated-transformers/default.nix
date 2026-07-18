{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curated-tokenizers,
  curated-transformers,
  setuptools,
  spacy,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "spacy-curated-transformers";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "spacy-curated-transformers";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-Y3puV9fDN5mAugLPmXuoIbwUBpSMcmkq+oXAyYdmQew=";
  };

  build-system = [ setuptools ];

  dependencies = [
    curated-tokenizers
    curated-transformers
    spacy
    torch
  ];

  pyproject = true;
  # Unit tests are hard to use, since most tests rely on downloading
  # models from Hugging Face Hub.
  pythonImportsCheck = [ "spacy_curated_transformers" ];

  pythonRelaxDeps = [
    "thinc"
  ];

  meta = {
    description = "spaCy entry points for Curated Transformers";
    homepage = "https://github.com/explosion/spacy-curated-transformers";
    changelog = "https://github.com/explosion/spacy-curated-transformers/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danieldk ];
  };
})
