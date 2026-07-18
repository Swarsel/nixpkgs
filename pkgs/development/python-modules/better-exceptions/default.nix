{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "better-exceptions";
  version = "0.3.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5Oa8GERNXwTm6JSxA4Hl6SHT1UQkBBgWLH21fp6zRTs=";
    pname = "better_exceptions";
  };

  # As noted by @WolfangAukang, some check files need to be disabled because of various errors, same with some tests.
  # After disabling and running the build, no tests are collected.
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "better_exceptions" ];

  meta = {
    description = "Pretty and more helpful exceptions in Python, automatically";
    homepage = "https://github.com/qix-/better-exceptions";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alex-nt ];
  };
}
