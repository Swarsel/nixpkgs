{
  lib,
  fetchFromGitHub,
  devpi-server,
  git,
  glibcLocales,
  nix-update-script,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "devpi-client";
  version = "7.2.1";

  src = fetchFromGitHub {
    owner = "devpi";
    repo = "devpi";
    tag = "client-${finalAttrs.version}";
    hash = "sha256-rAku3oHcmzFNA/MP/64382gCTgqopwjjy4S4HTEFZiY=";
  };

  buildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    devpi-server
    git
  ]
  ++ (with python3.pkgs; [
    mercurial
    mock
    packaging-legacy
    pypitoken
    pytestCheckHook
    sphinx
    virtualenv
    webtest
    wheel
  ]);

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  __darwinAllowLocalNetworking = true;

  build-system = with python3.pkgs; [
    setuptools
    setuptools-changelog-shortener
  ];

  dependencies = with python3.pkgs; [
    build
    check-manifest
    devpi-common
    iniconfig
    pkginfo
    pluggy
    platformdirs
    requests
  ];

  pyproject = true;

  pytestFlags = [
    # --fast skips tests which try to start a devpi-server improperly
    "--fast"
  ];

  pythonImportsCheck = [ "devpi" ];
  sourceRoot = "${finalAttrs.src.name}/client";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client for devpi, a pypi index server and packaging meta tool";
    homepage = "http://doc.devpi.net";
    changelog = "https://github.com/devpi/devpi/blob/client-${finalAttrs.version}/client/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lewo
      makefu
    ];

    mainProgram = "devpi";
  };
})
