{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  mypy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  sphinx-autodoc-typehints,
  sphinx-rtd-theme,
  sphinxHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "typeguard";
  version = "4.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9vjsu8gZybx0mYPMZ8AjkeFqm0O4sn8V3HDtfEoAcnQ=";
  };

  outputs = [
    "out"
    "doc"
  ];

  env.LC_ALL = "en_US.utf-8";

  nativeCheckInputs = [
    mypy
    pytestCheckHook
  ];

  # To prevent test from writing out non-reproducible .pyc files
  # https://github.com/agronholm/typeguard/blob/ca512c28132999da514f31b5e93ed2f294ca8f77/tests/test_typechecked.py#L641
  preCheck = "export PYTHONDONTWRITEBYTECODE=1";

  build-system = [
    glibcLocales
    setuptools
    setuptools-scm
    sphinxHook
    sphinx-autodoc-typehints
    sphinx-rtd-theme
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "typeguard" ];

  meta = {
    description = "This library provides run-time type checking for functions defined with argument type annotations";
    homepage = "https://github.com/agronholm/typeguard";
    changelog = "https://github.com/agronholm/typeguard/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
