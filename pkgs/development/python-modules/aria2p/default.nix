{
  lib,
  stdenv,
  fetchFromGitHub,
  aria2,
  asciimatics,
  buildPythonPackage,
  fastapi,
  loguru,
  pdm-backend,
  platformdirs,
  psutil,
  pyperclip,
  pytest-xdist,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  toml,
  uvicorn,
  websocket-client,
  withTui ? true,
}:

buildPythonPackage rec {
  pname = "aria2p";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "pawamoy";
    repo = "aria2p";
    tag = version;
    hash = "sha256-JEXTCDfFjxI1hooiEQq0KIGGoS2F7fyzOM0GMl+Jr7w=";
  };

  nativeCheckInputs = [
    aria2
    fastapi
    pytest-xdist
    pytestCheckHook
    responses
    psutil
    uvicorn
  ]
  ++ optional-dependencies.tui;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    loguru
    platformdirs
    requests
    setuptools # for pkg_resources
    toml
    websocket-client
  ]
  ++ lib.optionals withTui optional-dependencies.tui;

  disabledTests = [
    # require a running display server
    "test_add_downloads_torrents_and_metalinks"
    "test_add_downloads_uris"
    # require a running aria2 server
    "test_cli_autoclear_commands"
    "test_get_files_method"
    "test_pause_subcommand"
    "test_resume_method"
  ];

  optional-dependencies = {
    tui = [
      asciimatics
      pyperclip
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aria2p" ];

  meta = {
    description = "Command-line tool and library to interact with an aria2c daemon process with JSON-RPC";
    homepage = "https://github.com/pawamoy/aria2p";
    changelog = "https://github.com/pawamoy/aria2p/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ koral ];

    badPlatforms = [
      lib.systems.inspect.patterns.isDarwin
    ];

    mainProgram = "aria2p";
  };
}
