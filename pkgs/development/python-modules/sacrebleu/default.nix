{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  lxml,
  numpy,
  # Propagated build inputs
  portalocker,
  # Check inputs
  pytestCheckHook,
  regex,
  # build-system
  setuptools-scm,
  tabulate,
}:
let
  pname = "sacrebleu";
  version = "2.6.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "mjpost";
    repo = "sacrebleu";
    tag = "v${version}";
    hash = "sha256-R/lN39c/O3QcG70mD5ahUB4rK6Bd/vOvZMiYzYgrOjQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    portalocker
    regex
    tabulate
    numpy
    colorama
    lxml
  ];

  disabledTestPaths = [
    # require network access
    "test/test_api.py"
    "test/test_dataset.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sacrebleu" ];

  meta = {
    description = "Hassle-free computation of shareable, comparable, and reproducible BLEU, chrF, and TER scores";
    homepage = "https://github.com/mjpost/sacrebleu";
    changelog = "https://github.com/mjpost/sacrebleu/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "sacrebleu";
  };
}
