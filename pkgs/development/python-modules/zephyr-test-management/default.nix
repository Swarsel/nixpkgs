{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zephyr-test-management";
  version = "0.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bzRtiDoNbMfUKeHgVVomcX+RHaY2D0gAsWFuGahykVE=";
    pname = "zephyr_test_management";
  };

  # No tests in archive
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "zephyr" ];

  meta = {
    description = "Wrappers for both Zephyr Scale and Zephyr Squad (TM4J) REST APIs";
    homepage = "https://github.com/Steinhagen/zephyr-test-management";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rapiteanu ];
  };
}
