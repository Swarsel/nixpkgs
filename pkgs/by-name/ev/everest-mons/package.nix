{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "everest-mons";
  version = "2.0.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-E1yBTwZ4T2C3sXoLGz0kAcvas0q8tO6Aaiz3SHrT4ZE=";
    pname = "mons";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    dnfile
    pefile
    click
    tqdm
    xxhash
    pyyaml
    urllib3
    platformdirs
  ];

  pyproject = true;
  pythonImportsCheck = [ "mons" ];

  meta = {
    description = "Commandline Everest installer and mod manager for Celeste";
    homepage = "https://mons.coloursofnoise.ca/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    mainProgram = "mons";
  };
})
