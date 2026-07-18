{
  lib,
  stdenv,
  anyio,
  argon2-cffi,
  buildPythonPackage,
  fetchPypi,
  flaky,
  hatch-jupyter-builder,
  hatchling,
  ipykernel,
  jinja2,
  jupyter-client,
  jupyter-core,
  jupyter-events,
  jupyter-server-terminals,
  nbconvert,
  nbformat,
  overrides,
  packaging,
  prometheus-client,
  pytest-console-scripts,
  pytest-jupyter,
  pytest-timeout,
  pytestCheckHook,
  pyzmq,
  requests,
  send2trash,
  terminado,
  tornado,
  traitlets,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "jupyter-server";
  version = "2.17.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-w46omFZpZMiItHcq4e1Y7KhFkuiCUdLPxNFx+B9+mdU=";
    pname = "jupyter_server";
  };

  nativeCheckInputs = [
    ipykernel
    pytestCheckHook
    pytest-console-scripts
    pytest-jupyter
    pytest-timeout
    requests
    flaky
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export PATH=$out/bin:$PATH
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-jupyter-builder
    hatchling
  ];

  dependencies = [
    argon2-cffi
    jinja2
    tornado
    pyzmq
    traitlets
    jupyter-core
    jupyter-client
    jupyter-events
    jupyter-server-terminals
    nbformat
    nbconvert
    packaging
    send2trash
    terminado
    prometheus-client
    anyio
    websocket-client
    overrides
  ];

  disabledTestPaths = [
    "tests/services/kernels/test_api.py"
    "tests/services/sessions/test_api.py"
    # nbconvert failed: `relax_add_props` kwargs of validate has been
    # deprecated for security reasons, and will be removed soon.
    "tests/nbconvert/test_handlers.py"
  ];

  disabledTests = [
    "test_cull_idle"
    "test_server_extension_list"
    "test_subscribe_websocket"
    # test is presumable broken in sandbox
    "test_authorized_requests"
    # Fails under load on Hydra; kernel stays in 'starting' state due to a zmq socket error
    "test_cull_connected"
    "test_execution_state"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # attempts to use trashcan, build env doesn't allow this
    "test_delete"
    # Insufficient access privileges for operation
    "test_regression_is_hidden"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # Failed: DID NOT RAISE <class 'tornado.web.HTTPError'>
    "test_copy_big_dir"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    # TypeError: the JSON object must be str, bytes or bytearray, not NoneType
    "test_terminal_create_with_cwd"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
    # 19 failures on python 3.13:
    # ResourceWarning: unclosed database in <sqlite3.Connection object at 0x7ffff2a0cc70>
    # TODO: Can probably be removed at the next update
    "-Wignore::pytest.PytestUnraisableExceptionWarning"
  ];

  pythonImportsCheck = [ "jupyter_server" ];
  # https://github.com/NixOS/nixpkgs/issues/299427
  stripExclude = lib.optionals stdenv.hostPlatform.isDarwin [ "favicon.ico" ];

  meta = {
    description = "Backend—i.e. core services, APIs, and REST endpoints—to Jupyter web applications";
    homepage = "https://github.com/jupyter-server/jupyter_server";
    changelog = "https://github.com/jupyter-server/jupyter_server/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsdOriginal;
    mainProgram = "jupyter-server";
    teams = [ lib.teams.jupyter ];
  };
}
