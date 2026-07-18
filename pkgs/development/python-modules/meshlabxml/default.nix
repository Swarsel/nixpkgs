{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "meshlabxml";
  version = "2018.3";

  src = fetchPypi {
    inherit version;
    sha256 = "1villmg46hqby5jjkkpxr5bxydr72y5b3cbfngwpyxxdljn091w8";
    pname = "MeshLabXML";
  };

  propagatedBuildInputs = [ ];
  doCheck = false; # Upstream not currently have any tests.
  format = "setuptools";
  pythonImportsCheck = [ "meshlabxml" ];

  meta = {
    description = "Create and run MeshLab XML scripts with Python";
    homepage = "https://github.com/3DLIRIOUS/MeshLabXML";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ nh2 ];
  };
}
