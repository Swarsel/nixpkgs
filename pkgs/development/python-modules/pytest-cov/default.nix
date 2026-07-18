{
  lib,
  buildPythonPackage,
  coverage,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatchling,
  pytest,
  toml,
  tomli,
}:

buildPythonPackage rec {
  pname = "pytest-cov";
  version = "7.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MGdPK19jUaoJcCqcjDZPagHCeq4ME2augBYWDR78VrI=";
    pname = "pytest_cov";
  };

  buildInputs = [ pytest ];
  # xdist related tests fail with the following error
  # OSError: [Errno 13] Permission denied: 'py/_code'
  doCheck = false;

  checkPhase = ''
    # allow to find the module helper during the test run
    export PYTHONPATH=$PYTHONPATH:$PWD/tests
    py.test tests
  '';

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    coverage
    toml
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_cov" ];

  meta = {
    description = "Plugin for coverage reporting with support for both centralised and distributed testing, including subprocesses and multiprocessing";
    homepage = "https://github.com/pytest-dev/pytest-cov";
    changelog = "https://github.com/pytest-dev/pytest-cov/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
