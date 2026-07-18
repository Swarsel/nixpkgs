{
  lib,
  buildPythonPackage,
  fetchPypi,
  helpdev,
  qtpy,
}:

buildPythonPackage rec {
  pname = "qdarkstyle";
  version = "3.2.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DAt/dKbpISEAiZKzabq2BGgVfbHALNMNZKXpo7QC8a4=";
    pname = "QDarkStyle";
  };

  propagatedBuildInputs = [
    helpdev
    qtpy
  ];

  # No tests available
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Dark stylesheet for Python and Qt applications";
    homepage = "https://github.com/ColinDuquesnoy/QDarkStyleSheet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
