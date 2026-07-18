{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional-dependencies
  autopep8,
  # dependencies
  black,
  buildPythonPackage,
  docstring-to-markdown,
  flake8,
  # tests
  flaky,
  jedi,
  matplotlib,
  mccabe,
  numpy,
  pandas,
  pluggy,
  pycodestyle,
  pydocstyle,
  pyflakes,
  pylint,
  pytest-cov-stub,
  pytestCheckHook,
  python-lsp-jsonrpc,
  rope,
  setuptools,
  # build-system
  setuptools-scm,
  toml,
  ujson,
  versionCheckHook,
  websockets,
  whatthepatch,
  writableTmpDirAsHomeHook,
  yapf,
}:

buildPythonPackage rec {
  pname = "python-lsp-server";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-server";
    tag = "v${version}";
    hash = "sha256-Yq5dYaX+/hLvmPpHI8rhCcSlabQBPAyUrIQRgnoi17c=";
  };

  patches = [
    # https://github.com/python-lsp/python-lsp-server/pull/709
    ./jedi-compat.patch
  ];

  nativeCheckInputs = [
    flaky
    matplotlib
    numpy
    pandas
    pytest-cov-stub
    pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ optional-dependencies.all;

  build-system = [ setuptools-scm ];

  dependencies = [
    black
    docstring-to-markdown
    jedi
    pluggy
    python-lsp-jsonrpc
    setuptools # `pkg_resources`imported in pylsp/config/config.py
    ujson
  ];

  disabledTests = [
    # avoid dependencies on many Qt things just to run one singular test
    "test_pyqt_completion"

    # Flaky: ValueError: I/O operation on closed file
    "test_concurrent_ws_requests"

    # AttributeError: 'NoneType' object has no attribute 'plugin_manager'
    "test_missing_message"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # TimeoutError: rope/autoimport is slow under Nix's fs isolation on darwin
    "test_autoimport_code_actions_and_completions_for_notebook_document"
  ];

  optional-dependencies = {
    all = [
      autopep8
      flake8
      mccabe
      pycodestyle
      pydocstyle
      pyflakes
      pylint
      rope
      toml
      websockets
      whatthepatch
      yapf
    ];

    autopep8 = [ autopep8 ];
    flake8 = [ flake8 ];
    mccabe = [ mccabe ];
    pycodestyle = [ pycodestyle ];
    pydocstyle = [ pydocstyle ];
    pyflakes = [ pyflakes ];
    pylint = [ pylint ];
    rope = [ rope ];
    websockets = [ websockets ];

    yapf = [
      whatthepatch
      yapf
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "pylsp"
    "pylsp.python_lsp"
  ];

  pythonRelaxDeps = [
    "autopep8"
    "flake8"
    "jedi"
    "mccabe"
    "pycodestyle"
    "pydocstyle"
    "pyflakes"
  ];

  meta = {
    description = "Python implementation of the Language Server Protocol";
    homepage = "https://github.com/python-lsp/python-lsp-server";
    changelog = "https://github.com/python-lsp/python-lsp-server/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pylsp";
  };
}
