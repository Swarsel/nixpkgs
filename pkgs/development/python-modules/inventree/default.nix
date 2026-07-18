{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  coveralls,
  invoke,
  pillow,
  # tests
  pytestCheckHook,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "inventree";
  version = "0.23.2";

  src = fetchFromGitHub {
    owner = "inventree";
    repo = "inventree-python";
    tag = finalAttrs.version;
    hash = "sha256-YGzy58AbDdZGqkRNw/mRpcmbzsP5rBk2H9diz9RDhfM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    coveralls
    invoke
    pillow
    requests
  ];

  disabledTestPaths = [
    # Disable tests requiring dev server
    "test/test_base.py"
    "test/test_build.py"
    "test/test_company.py"
    "test/test_currency.py"
    "test/test_internal_price.py"
    "test/test_label.py"
    "test/test_order.py"
    "test/test_part.py"
    "test/test_plugin.py"
    "test/test_project_codes.py"
    "test/test_report.py"
    "test/test_stock.py"
  ];

  disabledTests = [
    # Disable tests requiring dev server
    "file_download"
    "timeout"
    "details"
    "token"
    "create_stuff"
    "add_result"
    "add_template"
    "get_widget"
  ];

  pyproject = true;
  pytestImportsCheck = [ "inventree" ];

  meta = {
    description = "Python library for communication with inventree via API";
    homepage = "https://github.com/inventree/inventree-python/";
    changelog = "https://github.com/inventree/inventree-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gigahawk
    ];
  };
})
