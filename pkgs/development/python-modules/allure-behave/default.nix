{
  lib,
  fetchFromGitHub,
  allure-python-commons,
  behave,
  buildPythonPackage,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "allure-behave";
  version = "2.15.3";

  src = fetchFromGitHub {
    owner = "allure-framework";
    repo = "allure-python";
    tag = version;
    hash = "sha256-06SKodvyoT0mYn4RmAIryZc+VyTI79KXFK+2/zuhzQ0=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools-scm ];

  dependencies = [
    allure-python-commons
    behave
  ];

  pyproject = true;
  pythonImportsCheck = [ "allure_behave" ];
  sourceRoot = "${src.name}/allure-behave";

  meta = {
    description = "Allure behave integration";
    homepage = "https://github.com/allure-framework/allure-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
