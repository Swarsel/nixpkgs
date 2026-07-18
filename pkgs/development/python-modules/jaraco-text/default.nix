{
  lib,
  autocommand,
  buildPythonPackage,
  fetchPypi,
  inflect,
  jaraco-context,
  jaraco-functools,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-text";
  version = "4.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-W3H+zqaatvk51MkGwE/uHtp2UA0WQRF99uxFuGXxDbA=";
    pname = "jaraco_text";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    autocommand
    jaraco-context
    jaraco-functools
    inflect
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "jaraco.text" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Module for text manipulation";
    homepage = "https://github.com/jaraco/jaraco.text";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
