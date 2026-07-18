{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  appdirs,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  defusedxml,
  devpi-common,
  # passthru
  devpi-server,
  execnet,
  gitUpdater,
  httpx,
  itsdangerous,
  nginx,
  nixosTests,
  packaging,
  packaging-legacy,
  passlib,
  platformdirs,
  pluggy,
  py,
  pyramid,
  pytest-asyncio,
  pytestCheckHook,
  repoze-lru,
  # build-system
  setuptools,
  strictyaml,
  testers,
  versionCheckHook,
  waitress,
  webtest,
}:

buildPythonPackage (finalAttrs: {
  pname = "devpi-server";
  version = "6.19.2";

  src = fetchFromGitHub {
    owner = "devpi";
    repo = "devpi";
    tag = "server-${finalAttrs.version}";
    hash = "sha256-rAku3oHcmzFNA/MP/64382gCTgqopwjjy4S4HTEFZiY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools_changelog_shortener",' ""
  '';

  nativeCheckInputs = [
    beautifulsoup4
    nginx
    pytest-asyncio
    pytestCheckHook
    webtest
  ];

  # root_passwd_hash tries to write to store
  # TestMirrorIndexThings tries to write to /var through ngnix
  # nginx tests try to write to /var
  preCheck = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    appdirs
    defusedxml
    devpi-common
    execnet
    httpx
    itsdangerous
    packaging
    packaging-legacy
    passlib
    platformdirs
    pluggy
    py
    pyramid
    repoze-lru
    setuptools
    strictyaml
    waitress
  ]
  ++ passlib.optional-dependencies.argon2;

  disabledTestPaths = [
    "test_devpi_server/test_nginx_replica.py"
    "test_devpi_server/test_streaming_nginx.py"
    "test_devpi_server/test_streaming_replica_nginx.py"
  ];

  disabledTests = [
    "test_fetch_later_deleted" # incompatible with newer pytest
  ];

  enabledTestPaths = [
    "./test_devpi_server"
  ];

  pyproject = true;

  pytestFlags = [
    "-rfsxX"
  ];

  pythonImportsCheck = [
    "devpi_server"
  ];

  sourceRoot = "${finalAttrs.src.name}/server";

  passthru.tests = {
    version = testers.testVersion {
      package = devpi-server;
    };

    devpi-server = nixosTests.devpi-server;
  };

  # devpi uses a monorepo for server, common, client and web
  passthru.updateScript = gitUpdater {
    rev-prefix = "server-";
  };

  meta = {
    description = "Github-style pypi index server and packaging meta tool";
    homepage = "http://doc.devpi.net";
    changelog = "https://github.com/devpi/devpi/blob/${finalAttrs.src.tag}/server/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      confus
      makefu
    ];

    mainProgram = "devpi-server";
  };
})
