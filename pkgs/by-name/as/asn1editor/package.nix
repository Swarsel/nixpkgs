{
  lib,
  fetchFromGitHub,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "asn1editor";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "Futsch1";
    repo = "asn1editor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mgluhC2DMS4OyS/BoWqBdVf7GcxquOtOKTHZ/hbiHQM=";
  };

  # Tests fail in sandbox, e.g.
  # "SystemExit: Unable to access the X Display, is $DISPLAY set properly?"
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
    wrapGAppsHook3
  ];

  dependencies = with python3.pkgs; [
    asn1tools
    coverage
    wxpython
  ];

  pyproject = true;
  pythonImportsCheck = [ "asn1editor" ];

  meta = {
    description = "Python based editor for ASN.1 encoded data";
    homepage = "https://github.com/Futsch1/asn1editor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
    mainProgram = "asn1editor";
  };
})
