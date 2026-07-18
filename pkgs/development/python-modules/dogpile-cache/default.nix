{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
  mako,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  stevedore,
}:

buildPythonPackage rec {
  pname = "dogpile-cache";
  version = "1.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hJxVc8mjjxVc1BcxA8cCtjft4DYcEuhkh2h30M0SXuw=";
    pname = "dogpile_cache";
  };

  nativeCheckInputs = [
    mako
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    decorator
    stevedore
  ];

  disabledTestPaths = [
    # flaky
    "tests/cache/test_dbm_backend.py"
    # timing sensitive
    "tests/test_lock.py::ConcurrencyTest"
  ];

  pyproject = true;

  meta = {
    description = "Caching front-end based on the Dogpile lock";
    homepage = "https://github.com/sqlalchemy/dogpile.cache";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
