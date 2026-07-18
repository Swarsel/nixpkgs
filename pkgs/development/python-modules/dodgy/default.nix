{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # pythonPackages
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dodgy";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "prospector-dev";
    repo = "dodgy";
    rev = version;
    sha256 = "0ywwjpz0p6ls3hp1lndjr9ql6s5lkj7dgpll1h87w04kwan70j0x";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  enabledTestPaths = [ "tests/test_checks.py" ];
  pyproject = true;

  meta = {
    description = "Looks at Python code to search for things which look \"dodgy\" such as passwords or diffs";
    homepage = "https://github.com/prospector-dev/dodgy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
    mainProgram = "dodgy";
  };
}
