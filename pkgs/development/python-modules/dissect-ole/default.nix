{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-ole";
  version = "3.12";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.ole";
    tag = version;
    hash = "sha256-ctPc9YLvu8IIEdgcSSYOvpQeqcrcLgTSZtzSiAvgCWk=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.ole" ];

  meta = {
    description = "Dissect module implementing a parser for the Object Linking & Embedding (OLE) format";
    homepage = "https://github.com/fox-it/dissect.ole";
    changelog = "https://github.com/fox-it/dissect.ole/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
