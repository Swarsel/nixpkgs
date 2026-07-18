{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  dotmap,
  gitUpdater,
  matplotlib,
  pyclipper,
  pytestCheckHook,
  pythonImportsCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "beziers";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "simoncozens";
    repo = "beziers.py";
    rev = "v${version}";
    hash = "sha256-NjmWsRz/NPPwXPbiSaOeKJMrYmSyNTt5ikONyAljgvM=";
  };

  nativeCheckInputs = [
    dotmap
    matplotlib
    pytestCheckHook
    pythonImportsCheckHook
  ];

  preCheck = ''
    # silence matplotlib warning
    export MPLCONFIGDIR=$(mktemp -d)
  '';

  build-system = [ setuptools ];
  dependencies = [ pyclipper ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails on macOS with Trace/BPT trap: 5 - something to do with recursion depth
    "test_cubic_cubic"
  ];

  pyproject = true;
  pythonImportsCheckFlags = [ "beziers" ];
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Python library for manipulating Bezier curves and paths in fonts";
    homepage = "https://github.com/simoncozens/beziers.py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
