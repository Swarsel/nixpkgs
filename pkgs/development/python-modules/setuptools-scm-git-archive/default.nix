{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "setuptools-scm-git-archive";
  version = "1.4.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xBi8d7OXTTrGXyaPBY8j4B3F+ZHyIzEosOFqad4iewk=";
    pname = "setuptools_scm_git_archive";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "setuptools_scm_git_archive" ];

  meta = {
    description = "setuptools_scm plugin for git archives";
    homepage = "https://github.com/Changaco/setuptools_scm_git_archive";
    license = lib.licenses.mit;
    maintainers = [ ];
    # https://github.com/Changaco/setuptools_scm_git_archive/pull/22
    broken = lib.versionAtLeast setuptools-scm.version "8";
  };
}
