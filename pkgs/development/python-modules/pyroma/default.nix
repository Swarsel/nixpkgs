{
  lib,
  fetchFromGitHub,
  # dependencies
  build,
  buildPythonPackage,
  docutils,
  flit-core,
  packaging,
  pygments,
  # test
  pytestCheckHook,
  pythonAtLeast,
  requests,
  # build-system
  setuptools,
  trove-classifiers,
}:

buildPythonPackage rec {
  pname = "pyroma";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "regebro";
    repo = "pyroma";
    tag = version;
    sha256 = "sha256-J5+/1jc/Dvh7aPV9FgG/uhxWG4DbQISgx+kX4Ayd1cU=";
  };

  propagatedBuildInputs = [
    build
    docutils
    flit-core
    packaging
    pygments
    setuptools
    requests
    trove-classifiers
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  # https://github.com/regebro/pyroma/issues/104
  disabled = pythonAtLeast "3.12";

  disabledTests = [
    # tries to reach pypi
    "test_complete"
    "test_distribute"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyroma" ];

  meta = {
    description = "Test your project's packaging friendliness";
    homepage = "https://github.com/regebro/pyroma";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
    mainProgram = "pyroma";
  };
}
