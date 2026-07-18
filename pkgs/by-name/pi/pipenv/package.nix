{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  pipenv,
  python3,
  runCommand,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

with python3.pkgs;

let

  runtimeDeps =
    ps:
    with ps;
    [
      certifi
      setuptools
      pip
      virtualenv
      virtualenv-clone
    ]
    ++ lib.optionals stdenv.hostPlatform.isAndroid [
      pyjnius
    ];

  pythonEnv = python3.withPackages runtimeDeps;

in
buildPythonApplication rec {
  pname = "pipenv";
  version = "2026.5.1";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "pipenv";
    tag = "v${version}";
    hash = "sha256-+8xUbpGIEuFboeK+JVVAt46gNcw1tfkmnTYt/IrISik=";
  };

  postPatch = ''
    # pipenv invokes python in a subprocess to create a virtualenv
    # and to call setup.py.
    # It would use sys.executable, which in our case points to a python that
    # does not have the required dependencies.
    substituteInPlace pipenv/utils/virtualenv.py \
      --replace "sys.executable" "'${pythonEnv.interpreter}'"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  propagatedBuildInputs = runtimeDeps python3.pkgs;
  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    mock
    pytestCheckHook
    pytest-xdist
    pytest-cov-stub
    pytz
    requests
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pipenv \
      --bash <(_PIPENV_COMPLETE=bash_source $out/bin/pipenv) \
      --zsh <(_PIPENV_COMPLETE=zsh_source $out/bin/pipenv) \
      --fish <(_PIPENV_COMPLETE=fish_source $out/bin/pipenv)
  '';

  build-system = [
    setuptools
  ];

  disabledTestPaths = [
    # many of these tests want access to the internet
    "tests/integration"
  ];

  disabledTests = [
    # this test wants access to the internet
    "test_download_file"
  ];

  pyproject = true;

  passthru.tests = {
    verify-venv-patch = runCommand "${pname}-test-verify-venv-patch" { } ''
      export PIPENV_VENV_IN_PROJECT=1

      # "pipenv install" should be able to create a venv
      ${pipenv}/bin/pipenv install

       # the venv exists
      [ -d .venv ]

      touch $out
    '';
  };

  meta = {
    description = "Python Development Workflow for Humans";
    homepage = "https://github.com/pypa/pipenv";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "pipenv";
  };
}
