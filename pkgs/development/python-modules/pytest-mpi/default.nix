{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mpi,
  mpi4py,
  pytest,
  pytestCheckHook,
  setuptools,
  sybil,
}:

buildPythonPackage rec {
  pname = "pytest-mpi";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "aragilar";
    repo = "pytest-mpi";
    rev = "v${version}";
    hash = "sha256-m3HTGLoPnYeg0oeIA1nzTzch7FtkuXTYpox4rRgo5MU=";
  };

  buildInputs = [
    # Don't propagate it to let a different pytest version be used if needed
    pytest
  ];

  # Tests cause the Python interpreter to crash from some reason, a hard issue
  # to debug. (TODO: discuss this with upstream)
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    mpi
    mpi4py
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    sybil
  ];

  pyproject = true;

  pytestFlags = [
    # https://github.com/aragilar/pytest-mpi/issues/4#issuecomment-634614337
    "-ppytester"
  ];

  pythonImportsCheck = [ "pytest_mpi" ];

  meta = {
    description = "Pytest plugin for working with MPI";
    homepage = "https://github.com/aragilar/pytest-mpi";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
