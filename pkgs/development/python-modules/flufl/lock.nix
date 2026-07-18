{
  lib,
  atpublic,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  psutil,
  pytest-cov-stub,
  pytestCheckHook,
  sybil,
}:

buildPythonPackage rec {
  pname = "flufl-lock";
  version = "9.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jXPIjKt8mLeSZxApnBFivsfOJT+bnF8KLKgDf58kAjQ=";
    pname = "flufl_lock";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    sybil
  ];

  build-system = [ hatchling ];

  dependencies = [
    atpublic
    psutil
  ];

  pyproject = true;
  # disable code coverage checks for all OS. Upstream does not enforce these
  # checks on Darwin, and code coverage cannot be improved downstream nor is it
  # relevant to the user.
  pytestFlags = [ "--no-cov" ];
  pythonImportsCheck = [ "flufl.lock" ];
  pythonNamespaces = [ "flufl" ];

  meta = {
    description = "NFS-safe file locking with timeouts for POSIX and Windows";
    homepage = "https://flufllock.readthedocs.io/";
    changelog = "https://gitlab.com/warsaw/flufl.lock/-/blob/${version}/docs/NEWS.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qyliss ];
  };
}
