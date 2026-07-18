{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "qlever-control";
  version = "0.5.48";

  src = fetchFromGitHub {
    owner = "qlever-dev";
    repo = "qlever-control";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mjWMRXRo2iU8C8fArXTcuVmts67MuCq8nR9dD87nR1g=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    argcomplete
    psutil
    pyyaml
    rdflib
    requests-sse
    termcolor
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "qlever"
  ];

  meta = {
    description = "Command-line tool for controlling the QLever graph database";
    homepage = "https://github.com/qlever-dev/qlever-control";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "qlever";
    teams = with lib.teams; [ ngi ];
  };
})
