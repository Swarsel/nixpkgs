{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bibtexparser";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "sciunto-org";
    repo = "python-${finalAttrs.pname}";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9zLJZAk2IBYTL7lACh6erY7A44XFZGJCr8dcpYlwKRI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyparsing ];
  pyproject = true;
  pythonImportsCheck = [ "bibtexparser" ];

  meta = {
    description = "Bibtex parser for Python";
    homepage = "https://github.com/sciunto-org/python-bibtexparser";

    license = with lib.licenses; [
      lgpl3Only # or
      bsd3
    ];
  };
})
