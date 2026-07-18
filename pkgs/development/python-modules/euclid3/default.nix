{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "euclid3";
  version = "0.01";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JbgnpXrb/Zo/qGJeQ6vD6Qf2HeYiND5+U4SC75tG/Qs=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "euclid3" ];

  meta = {
    description = "2D and 3D vector, matrix, quaternion and geometry module";
    homepage = "http://code.google.com/p/pyeuclid/";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      jfly
      matusf
    ];
  };
}
