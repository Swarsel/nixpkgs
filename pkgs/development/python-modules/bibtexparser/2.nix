{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pylatexenc,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bibtexparser";
  version = "2.0.0b9";

  src = fetchFromGitHub {
    owner = "sciunto-org";
    repo = "python-bibtexparser";
    tag = "v${version}";
    hash = "sha256-viBY2hZXsXsfjpi7zMFh3CwQFOKL41F3x0IKULelo/o=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pylatexenc ];
  pyproject = true;
  pythonImportsCheck = [ "bibtexparser" ];

  meta = {
    description = "Bibtex parser for Python";
    homepage = "https://github.com/sciunto-org/python-bibtexparser";
    changelog = "https://github.com/sciunto-org/python-bibtexparser/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
  };
}
