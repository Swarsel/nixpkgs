{
  lib,
  buildPythonPackage,
  chardet,
  fetchPypi,
  graphviz,
  parameterized,
  pyparsing,
  pytestCheckHook,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydot";
  version = "4.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-whSPaBxKM+CL8OJqnl+OQJmoLg4qBoCY8yzoZXc2StU=";
  };

  patches = [
    (replaceVars ./hardcode-graphviz-path.patch {
      inherit graphviz;
    })
  ];

  nativeCheckInputs = [
    chardet
    parameterized
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [ pyparsing ];
  enabledTestPaths = [ "test/test_pydot.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pydot" ];

  meta = {
    description = "Allows to create both directed and non directed graphs from Python";
    homepage = "https://github.com/erocarrera/pydot";
    changelog = "https://github.com/pydot/pydot/blob/v${version}/ChangeLog";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
