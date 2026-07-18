{
  lib,
  buildPythonPackage,
  cssselect,
  fetchPypi,
  lxml,
  pytestCheckHook,
  requests,
  setuptools,
  webob,
  webtest,
}:

buildPythonPackage rec {
  pname = "pyquery";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AZS7JwaxLQN9sSxRko/p67NrctnnGVZdq6WmxZUyL68=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
    webob
    (webtest.overridePythonAttrs (_: {
      # circular dependency
      doCheck = false;
    }))
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    cssselect
    lxml
  ];

  disabledTestPaths = [
    # requires network
    "tests/test_pyquery.py::TestWebScrappingEncoding::test_get"
  ];

  disabledTests = [
    # broken in libxml 2.14 update
    # https://github.com/gawel/pyquery/issues/257
    "test_val_for_textarea"
    "test_replaceWith"
    "test_replaceWith_with_function"
    "test_get"
    "test_post"
    "test_session"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyquery" ];

  meta = {
    description = "Jquery-like library for Python";
    homepage = "https://github.com/gawel/pyquery";
    changelog = "https://github.com/gawel/pyquery/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
  };
}
