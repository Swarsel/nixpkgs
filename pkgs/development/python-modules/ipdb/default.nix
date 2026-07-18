{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
  ipython,
  isPyPy,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipdb";
  version = "0.13.13";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-46xgGO8FEm1EKvaAqthjAG7BnQIpBWGsiLixwLDPxyY=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    ipython
    decorator
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabled = isPyPy; # setupterm: could not find terminfo database

  disabledTestPaths = [
    # OSError: pytest: reading from stdin while output is captured!  Consider using `-s`.
    "manual_test.py"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # tests get stuck
    "tests/test_opts.py"
  ];

  pyproject = true;

  meta = {
    description = "IPython-enabled pdb";
    homepage = "https://github.com/gotcha/ipdb";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    mainProgram = "ipdb3";
  };
}
