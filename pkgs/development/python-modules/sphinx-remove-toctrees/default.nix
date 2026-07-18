{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  ipython,
  myst-parser,
  pre-commit,
  pytest,
  sphinx,
  sphinx-book-theme,
}:

buildPythonPackage rec {
  pname = "sphinx-remove-toctrees";
  version = "1.0.0.post1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-SAjR7fFRwG7/bSw5Iux+vJ/Tqhdi3hsuFnSjf1rJzi0=";
    pname = "sphinx_remove_toctrees";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    sphinx
  ];

  optional-dependencies = {
    code_style = [
      pre-commit
    ];

    docs = [
      ipython
      myst-parser
      sphinx-book-theme
    ];

    tests = [
      ipython
      myst-parser
      pytest
      sphinx-book-theme
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "sphinx_remove_toctrees"
  ];

  meta = {
    description = "Reduce your documentation build size by selectively removing toctrees from pages";
    homepage = "https://pypi.org/project/sphinx-remove-toctrees/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
