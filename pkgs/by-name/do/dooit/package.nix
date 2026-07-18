{
  lib,
  fetchFromGitHub,
  dooit,
  nix-update-script,
  python3,
  testers,
  extraPackages ? [ ],
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "dooit";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "dooit-org";
    repo = "dooit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A3l+E9B2fWyNpDzMr8WRiiHD/fIcUzcIwtmur+2Mk0k=";
  };

  propagatedBuildInputs =
    with python3.pkgs;
    [
      pyperclip
      textual
      pyyaml
      python-dateutil
      sqlalchemy
      platformdirs
      tzlocal
      click
    ]
    ++ extraPackages;

  # /homeless-shelter
  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    faker
    pytest-asyncio
  ];

  build-system = with python3.pkgs; [ hatchling ];
  pyproject = true;

  pythonRelaxDeps = [
    "tzlocal"
    "textual"
    "sqlalchemy"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "HOME=$(mktemp -d) dooit --version";
      package = dooit;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "TUI todo manager";
    homepage = "https://github.com/dooit-org/dooit";
    changelog = "https://github.com/dooit-org/dooit/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      khaneliman
      wesleyjrz
      kraanzu
    ];

    mainProgram = "dooit";
  };
})
