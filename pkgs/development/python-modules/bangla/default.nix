{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "bangla";
  version = "0.0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rX2/rUUf9g4otYMNX0LDPXSIDRbIE8xRl95NamHzRwQ=";
  };

  # https://github.com/arsho/bangla/issues/5
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "bangla" ];

  meta = {
    description = "Bangla is a package for Bangla language users with various functionalities including Bangla date and Bangla numeric conversation";
    homepage = "https://github.com/arsho/bangla";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
