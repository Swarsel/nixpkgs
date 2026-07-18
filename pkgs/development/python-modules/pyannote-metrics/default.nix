{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # undeclared cli dependencies
  docopt,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  numpy,
  pandas,
  pyannote-core,
  pyannote-database,
  # tests
  pytestCheckHook,
  scikit-learn,
  scipy,
  tabulate,
  typing-extensions,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "pyannote-metrics";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "pyannote";
    repo = "pyannote-metrics";
    tag = version;
    hash = "sha256-j0rNzHX9xIP9LB2Rk5D0EsD5BOWR4Kp5CEuKi8l8QgY=";
  };

  postPatch = ''
    substituteInPlace src/pyannote/metrics/cli.py \
      --replace-fail \
        'version="Evaluation"' \
        'version="${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    numpy
    pandas
    pyannote-core
    pyannote-database
    scikit-learn
    scipy
    # Imported in pyannote/metrics/cli.py
    docopt
    tabulate
    # Imporrted in pyannote/metrics/types.py
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyannote.metrics" ];

  meta = {
    description = "Toolkit for reproducible evaluation, diagnostic, and error analysis of speaker diarization systems";
    homepage = "https://github.com/pyannote/pyannote-metrics";
    changelog = "http://pyannote.github.io/pyannote-metrics/changelog.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pyannote-metrics";
  };
}
