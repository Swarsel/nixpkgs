{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  statsmodels,
}:

buildPythonPackage {
  pname = "changefinder";
  version = "unstable-2024-03-24";

  src = fetchFromGitHub {
    owner = "shunsukeaihara";
    repo = "changefinder";
    rev = "58c8c32f127b9e46f9823f36221f194bdb6f3f8b";
    hash = "sha256-1If0gIsMU8673fKSSHVMvDgR1UnYgM/4HiyvZJ9T6VM=";
  };

  patches = [ ./fix_test_invocation.patch ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    statsmodels
  ];

  enabledTestPaths = [ "test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "changefinder" ];
  pythonRemoveDeps = [ "nose" ];

  meta = {
    description = "Online Change-Point Detection library based on ChangeFinder algorithm";
    homepage = "https://github.com/shunsukeaihara/changefinder";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
