{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  pluggy,
  pyhamcrest,
  python,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "allure-python-commons-test";
  version = "2.16.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-otfGxWNnbMUGuQcqsroOOfiqhCQqe25c39Ur57ek2og=";
    pname = "allure_python_commons_test";
  };

  checkPhase = ''
    ${python.interpreter} -m doctest ./src/container.py
    ${python.interpreter} -m doctest ./src/report.py
    ${python.interpreter} -m doctest ./src/label.py
    ${python.interpreter} -m doctest ./src/result.py
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    attrs
    pluggy
    six
    pyhamcrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "allure_commons_test" ];

  meta = {
    description = "Just pack of hamcrest matchers for validation result in allure2 json format";
    homepage = "https://github.com/allure-framework/allure-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evanjs ];
  };
}
