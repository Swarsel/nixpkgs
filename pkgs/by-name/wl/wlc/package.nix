{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "wlc";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aljCKtVrVyHCz6jd6XtBbhi1xm207lc25DU+1bqJYos=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    argcomplete
    python-dateutil
    requests
    pyxdg
    responses
    twine
  ];

  pyproject = true;
  pythonImportsCheck = [ "wlc" ];

  meta = {
    description = "Weblate commandline client using Weblate's REST API";
    homepage = "https://github.com/WeblateOrg/wlc";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ paperdigits ];
    mainProgram = "wlc";
  };
}
