{
  lib,
  fetchFromGitHub,
  colorz,
  imagemagick,
  installShellFiles,
  nix-update-script,
  python3,
  withColorthief ? false,
  withColorz ? false,
  withFastColorthief ? false,
  withHaishoku ? false,
  withModernColorthief ? false,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pywal16";
  version = "3.8.15";

  src = fetchFromGitHub {
    owner = "eylles";
    repo = "pywal16";
    tag = version;
    hash = "sha256-2KlVeOrF/nfRZk12gthDJ08xNvVbP5em3eXPMudo1Vs=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
    imagemagick
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = ''
    installManPage data/man/man1/wal.1
  '';

  build-system = [ python3.pkgs.setuptools ];

  dependencies =
    lib.optionals withColorthief optional-dependencies.colorthief
    ++ lib.optionals withColorz optional-dependencies.colorz
    ++ lib.optionals withFastColorthief optional-dependencies.fast-colorthief
    ++ lib.optionals withHaishoku optional-dependencies.haishoku
    ++ lib.optionals withModernColorthief optional-dependencies.modern_colorthief;

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath ([ imagemagick ] ++ lib.optional withColorz colorz)}"
  ];

  optional-dependencies = with python3.pkgs; {
    all = [
      colorthief
      colorz
      fast-colorthief
      haishoku
      modern-colorthief
    ];

    colorthief = [ colorthief ];
    colorz = [ colorz ];
    fast-colorthief = [ fast-colorthief ];
    haishoku = [ haishoku ];
    modern_colorthief = [ modern-colorthief ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pywal" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "16 colors fork of pywal";
    homepage = "https://github.com/eylles/pywal16";
    changelog = "https://github.com/eylles/pywal16/blob/refs/tags/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "wal";
  };
}
