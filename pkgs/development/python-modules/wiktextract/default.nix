{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  levenshtein,
  nltk,
  pydantic,
  setuptools,
  unstableGitUpdater,
  wikitextprocessor,
}:

buildPythonPackage {
  pname = "wiktextract";
  version = "1.99.7-unstable-2026-03-26";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = "wiktextract";
    rev = "f47b8fc87a0e17f4dcca68f534e73f4c6fa8e8e7";
    hash = "sha256-U9Xm3vRAvONN/DwyhEEM54eiBnv7JKAEXPolK9HfJU8=";
  };

  # It requires Internet
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    levenshtein
    nltk
    pydantic
    wikitextprocessor
  ];

  pyproject = true;
  pythonImportsCheck = [ "wiktextract" ];
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Wiktionary dump file parser and multilingual data extractor";
    homepage = "https://github.com/tatuylonen/wiktextract";

    license = with lib.licenses; [
      mit
      cc-by-sa-40 # Needed for certain test files under Wiktionary licence
    ];

    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "wiktwords";
  };
}
