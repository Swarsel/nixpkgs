{
  lib,
  fetchFromGitHub,
  gitUpdater,
  nixosTests,
  python3,
  qt6,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "maestral-qt";
  version = "1.9.5";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FCn9ELbodk+zCJNmlOVoxE/KSSqbxy5HTB1vpiu7AJA=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  buildInputs = [
    qt6.qtwayland
    qt6.qtbase
    qt6.qtsvg # Needed for the systray icon
  ];

  # no tests
  doCheck = false;

  postInstall = ''
    install -Dm444 -t $out/share/icons/hicolor/512x512/apps src/maestral_qt/resources/maestral.png
  '';

  preFixup = ''
    # Add all necessary QT variables
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  __structuredAttrs = true;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    click
    markdown2
    maestral
    packaging
    pyqt6
  ];

  dontWrapQtApps = true;

  makeWrapperArgs = with python3.pkgs; [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix"
    "PYTHONPATH"
    ":"
    (makePythonPath (requiredPythonModules maestral.propagatedBuildInputs))
    "--prefix"
    "PYTHONPATH"
    ":"
    (makePythonPath [ maestral ])
  ];

  pyproject = true;
  pythonImportsCheck = [ "maestral_qt" ];

  passthru = {
    tests.maestral = nixosTests.maestral;

    updateScript = gitUpdater {
      ignoredVersions = "dev";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "GUI front-end for maestral (an open-source Dropbox client) for Linux";
    homepage = "https://maestral.app";
    changelog = "https://github.com/samschott/maestral/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      peterhoeg
      sfrijters
    ];

    platforms = lib.platforms.linux;
    mainProgram = "maestral_qt";
  };
})
