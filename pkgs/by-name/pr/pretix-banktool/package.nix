{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pretix-banktool";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-banktool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-x6P+WqrOak5/gmMEmBkHrx6kPsbSOAXbKRbndFG3IJU=";
  };

  doCheck = false; # no tests
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    fints
    requests
    mt-940
  ];

  pyproject = true;
  pythonImportsCheck = [ "pretix_banktool" ];
  pythonRelaxDeps = [ "fints" ];

  meta = {
    description = "Automatic bank data upload tool for pretix (with FinTS client)";
    homepage = "https://github.com/pretix/pretix-banktool";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "pretix-banktool";
  };
})
