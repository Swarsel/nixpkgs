{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  networkx,
  numpy,
  pypng,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "matplotx";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "nschloe";
    repo = "matplotx";
    rev = "v${version}";
    hash = "sha256-EWEiEY23uFwd/vgWVLCH/buUmgRqz1rqqlJEdXINYMg=";
  };

  propagatedBuildInputs = [
    setuptools
    matplotlib
    numpy
  ];

  # This variable is needed to suppress the "Trace/BPT trap: 5" error in Darwin's checkPhase.
  # Not sure of the details, but we can avoid it by changing the matplotlib backend during testing.
  env.MPLBACKEND = lib.optionalString stdenv.hostPlatform.isDarwin "Agg";
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.all;

  disabledTestPaths = [
    "tests/test_spy.py" # Requires meshzoo (non-free) and pytest-codeblocks (not packaged)
  ];

  optional-dependencies = {
    all = [
      networkx
      pypng
      scipy
    ];

    contour = [ networkx ];

    spy = [
      pypng
      scipy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "matplotx" ];

  meta = {
    description = "More styles and useful extensions for Matplotlib";
    homepage = "https://github.com/nschloe/matplotx";
    changelog = "https://github.com/nschloe/matplotx/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ swflint ];
    mainProgram = "matplotx";
  };
}
