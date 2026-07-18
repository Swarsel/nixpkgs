{
  lib,
  fetchFromGitHub,
  allure-python-commons,
  buildPythonPackage,
  pytest,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "allure-pytest";
  version = "2.15.3";

  src = fetchFromGitHub {
    owner = "allure-framework";
    repo = "allure-python";
    tag = version;
    hash = "sha256-06SKodvyoT0mYn4RmAIryZc+VyTI79KXFK+2/zuhzQ0=";
  };

  buildInputs = [ pytest ];
  # Tests were moved to the meta package
  doCheck = false;
  build-system = [ setuptools-scm ];
  dependencies = [ allure-python-commons ];
  pyproject = true;
  pythonImportsCheck = [ "allure_pytest" ];
  sourceRoot = "${src.name}/allure-pytest";

  meta = {
    description = "Allure integrations for Python test frameworks";
    homepage = "https://github.com/allure-framework/allure-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evanjs ];
  };
}
