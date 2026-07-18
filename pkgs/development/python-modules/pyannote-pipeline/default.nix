{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  docopt,
  filelock,
  # build-system
  hatch-vcs,
  hatchling,
  optuna,
  pyannote-core,
  pyannote-database,
  # tests
  pytestCheckHook,
  pyyaml,
  scipy,
  tqdm,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "pyannote-pipeline";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "pyannote";
    repo = "pyannote-pipeline";
    tag = version;
    hash = "sha256-H2yIeCKhZFUkZXww+eaRKMzJrbALdARady02fq/pJrU=";
  };

  postPatch = ''
    substituteInPlace src/pyannote/pipeline/experiment.py \
      --replace-fail \
        'version="Tunable pipelines"' \
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
    docopt # imported in pyannote/pipeline/experiment.py
    filelock
    optuna
    pyannote-core
    pyannote-database
    pyyaml
    scipy # imported in pyannote/pipeline/optimizer.py
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyannote.pipeline" ];

  meta = {
    description = "Tunable pipelines";
    homepage = "https://github.com/pyannote/pyannote-pipeline";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pyannote-pipeline";
  };
}
