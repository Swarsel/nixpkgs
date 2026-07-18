{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "takethetime";
  version = "0.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2+MEU6G1lqOPni4/qOGtxa8tv2RsoIN61cIFmhb+L/k=";
    pname = "TakeTheTime";
  };

  # all tests are timing dependent
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "takethetime" ];

  meta = {
    description = "Simple time taking library using context managers";
    homepage = "https://github.com/ErikBjare/TakeTheTime";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ huantian ];
  };
}
