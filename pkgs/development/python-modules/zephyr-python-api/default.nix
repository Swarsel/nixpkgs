{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zephyr-python-api";
  version = "0.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-YupGiybfhwb+I4ofr6RNBzS6LQfx5BQD/SU5nYrnqFk=";
    pname = "zephyr_python_api";
  };

  # No tests in archive
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "zephyr" ];

  meta = {
    description = "Set of wrappers for Zephyr Scale (TM4J) REST API";
    homepage = "https://github.com/nassauwinter/zephyr-python-api";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rapiteanu ];
  };
}
