{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
  python3Packages,
  wrapGAppsHook3,
  enableDbusUi ? true,
}:

python3Packages.buildPythonApplication rec {
  pname = "pantalaimon";
  version = "0.10.6";

  # pypi tarball miss tests
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "pantalaimon";
    rev = version;
    hash = "sha256-g+ZWarZnjlSOpD75yf53Upqj1qDlil7pdbfEsMAsjh0=";
  };

  nativeBuildInputs = lib.optionals enableDbusUi [
    wrapGAppsHook3
  ];

  # darwin has difficulty communicating with server, fails some integration tests
  # Tests are incompatible with pytest>=8 and Python 3.13
  doCheck = !stdenv.hostPlatform.isDarwin && python3Packages.pythonOlder "3.13";

  nativeCheckInputs =
    with python3Packages;
    [
      aioresponses
      faker
      pytest-aiohttp
      pytestCheckHook
    ]
    ++ lib.concatAttrValues optional-dependencies;

  postInstall = ''
    installManPage docs/man/*.[1-9]
  '';

  build-system = [
    installShellFiles
  ]
  ++ (with python3Packages; [
    setuptools
  ]);

  dependencies =
    with python3Packages;
    [
      aiohttp
      attrs
      cachetools
      click
      janus
      keyring
      logbook
      (matrix-nio.override { withOlm = true; })
      peewee
      platformdirs
      prompt-toolkit
    ]
    ++ lib.optionals enableDbusUi optional-dependencies.ui;

  dontWrapGApps = enableDbusUi;

  makeWrapperArgs = lib.optionals enableDbusUi [
    "\${gappsWrapperArgs[@]}"
  ];

  optional-dependencies.ui = with python3Packages; [
    dbus-python
    notify2
    pygobject3
    pydbus
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "matrix-nio"
  ];

  passthru.tests = {
    inherit (nixosTests) pantalaimon;
  };

  meta = {
    description = "End-to-end encryption aware Matrix reverse proxy daemon";
    homepage = "https://github.com/matrix-org/pantalaimon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ valodim ];
  };
}
