{
  lib,
  allure-python-commons-test,
  attrs,
  buildPythonPackage,
  fetchPypi,
  pluggy,
  python,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "allure-python-commons";
  version = "2.15.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tCqW1gdvsyPJ5DZF37hMBXT2utCg4AXZJWQBXNFy1WQ=";
    pname = "allure_python_commons";
  };

  build-system = [ setuptools-scm ];

  dependencies = [
    attrs
    pluggy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "allure"
    "allure_commons"
  ];

  meta = {
    description = "Common engine for all modules. It is useful for make integration with your homemade frameworks";
    homepage = "https://github.com/allure-framework/allure-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evanjs ];
  };
}
