{
  lib,
  fetchPypi,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "legit";
  version = "1.2.0.post0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-lJOWtoApqK9AWrIMkBkCNB72vVXH/sbatxFB1j1AaxE=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    clint
    crayons
    gitpython
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "legit" ];

  meta = {
    description = "Git for Humans, Inspired by GitHub for Mac";
    homepage = "https://github.com/frostming/legit";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ryneeverett ];
    mainProgram = "legit";
  };
})
