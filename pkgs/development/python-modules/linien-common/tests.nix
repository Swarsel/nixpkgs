{
  buildPythonPackage,
  cma,
  linien-client,
  linien-common,
  matplotlib,
  migen,
  misoc,
  pytest-plt,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (linien-common) version src;
  pname = "linien-tests";

  nativeCheckInputs = [
    cma
    linien-client
    linien-common
    matplotlib
    migen
    misoc
    pytest-plt
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabledTestPaths = [
    # require linien-server which is not packaged
    "tests/test_algorithm_selection.py"
    "tests/test_approacher.py"
    "tests/test_optimizer_engines.py"
    "tests/test_optimizer_utils.py"
    "tests/test_robust_autolock.py"
    "tests/test_simple_autolock_cpu.py"
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
