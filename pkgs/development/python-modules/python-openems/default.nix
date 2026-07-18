{
  lib,
  boost,
  buildPythonPackage,
  csxcad,
  cython_0,
  h5py,
  numpy,
  openems,
  python-csxcad,
}:

buildPythonPackage rec {
  pname = "python-openems";
  version = openems.version;
  src = openems.src;

  nativeBuildInputs = [
    cython_0
    boost
  ];

  propagatedBuildInputs = [
    openems
    csxcad
    python-csxcad
    numpy
    h5py
  ];

  format = "setuptools";
  pythonImportsCheck = [ "openEMS" ];

  setupPyBuildFlags = [
    "-I${openems}/include"
    "-L${openems}/lib"
    "-R${openems}/lib"
  ];

  sourceRoot = "${src.name}/python";

  meta = {
    description = "Python interface to OpenEMS";
    homepage = "http://openems.de/index.php/Main_Page.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthuszagh ];
    platforms = lib.platforms.linux;
  };
}
