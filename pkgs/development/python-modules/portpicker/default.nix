{
  lib,
  buildPythonPackage,
  fetchPypi,
  psutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "portpicker";
  version = "1.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vVB/1vlvZe4CeB8uZ06dxsmbv6bjw5mS45FiBMnUMfo=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ psutil ];
  pyproject = true;
  pythonImportsCheck = [ "portpicker" ];

  meta = {
    description = "Library to choose unique available network ports";
    homepage = "https://github.com/google/python_portpicker";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "portserver.py";
  };
}
