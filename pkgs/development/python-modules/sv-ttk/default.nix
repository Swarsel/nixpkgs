{
  lib,
  buildPythonPackage,
  fetchPypi,
  tkinter,
}:

buildPythonPackage rec {
  pname = "sv-ttk";
  version = "2.6.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-R1idXiA5jPQE6DYvJPPtSPODDNCs4FbYM1T6Jdjk/kg=";
    pname = "sv_ttk";
  };

  propagatedBuildInputs = [ tkinter ];
  # No tests available
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "sv_ttk" ];

  meta = {
    description = "Gorgeous theme for Tkinter/ttk, based on the Sun Valley visual style";
    homepage = "https://github.com/rdbende/Sun-Valley-ttk-theme";
    changelog = "https://github.com/rdbende/Sun-Valley-ttk-theme/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ AngryAnt ];
  };
}
