{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dicttoxml2,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pyialarm";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "RyuzakiKK";
    repo = "pyialarm";
    rev = "v${version}";
    hash = "sha256-rOdeYewjoFVbHdNPHN6ZC2g6X5yr84/JFE6tGSDIoRU=";
  };

  propagatedBuildInputs = [
    dicttoxml2
    xmltodict
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyialarm" ];

  meta = {
    description = "Python library to interface with Antifurto365 iAlarm systems";
    homepage = "https://github.com/RyuzakiKK/pyialarm";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
