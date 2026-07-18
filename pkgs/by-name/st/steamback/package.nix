{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "steamback";
  version = "0.3.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-hvMPSxIfwwQqo80JCpYhcbVY4kXs5jWtjjafVSMrw6o=";
  };

  checkPhase = ''
    runHook preCheck

    $out/bin/steamback --help

    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = with python3Packages; [
    psutil
    async-tkinter-loop
    timeago
    platformdirs
    sv-ttk
    pillow
  ];

  pyproject = true;

  pythonImportsCheck = [
    "steamback"
    "steamback.gui"
    "steamback.test"
    "steamback.util"
  ];

  pythonRelaxDeps = [
    "async-tkinter-loop"
    "platformdirs"
    "pillow"
    "psutil"
  ];

  meta = {
    description = "Decky plugin to add versioned save-game snapshots to Steam-cloud enabled games";
    homepage = "https://github.com/geeksville/steamback";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ AngryAnt ];
    mainProgram = "steamback";
  };
})
