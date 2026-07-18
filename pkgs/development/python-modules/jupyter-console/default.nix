{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  flaky,
  # build-system
  hatchling,
  # dependencies
  ipykernel,
  ipython,
  jupyter-client,
  jupyter-core,
  pexpect,
  prompt-toolkit,
  pygments,
  pytestCheckHook,
  pyzmq,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyter-console";
  version = "6.6.3";

  src = fetchFromGitHub {
    owner = "jupyter";
    repo = "jupyter_console";
    tag = "v${version}";
    hash = "sha256-jdSeZCspcjEQVBpJyxVnwJ5SAq+SS1bW9kqp/F/zwCQ=";
  };

  postPatch =
    # Use wrapped executable in tests
    let
      binPath = "${placeholder "out"}/bin/jupyter-console";
    in
    ''
      substituteInPlace jupyter_console/tests/test_console.py \
        --replace-fail "'-m', 'jupyter_console', " "" \
        --replace-fail "sys.executable" "'${binPath}'"
    '';

  nativeCheckInputs = [
    flaky
    pexpect
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    ipykernel
    ipython
    jupyter-client
    jupyter-core
    prompt-toolkit
    pygments
    pyzmq
    traitlets
  ];

  disabledTests = [
    # Flaky: pexpect.exceptions.TIMEOUT: Timeout exceeded
    "test_console_starts"
    "test_display_text"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_console" ];

  meta = {
    description = "Jupyter terminal console";
    homepage = "https://github.com/jupyter/jupyter_console";
    changelog = "https://github.com/jupyter/jupyter_console/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    mainProgram = "jupyter-console";
    teams = [ lib.teams.jupyter ];
  };
}
