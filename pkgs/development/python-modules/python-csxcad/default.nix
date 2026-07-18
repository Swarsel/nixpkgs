{
  lib,
  buildPythonPackage,
  csxcad,
  cython,
  matplotlib,
  numpy,
  openems,
}:

buildPythonPackage rec {
  pname = "python-csxcad";
  version = csxcad.version;
  src = csxcad.src;
  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [
    openems
    csxcad
    numpy
    matplotlib
  ];

  format = "setuptools";

  setupPyBuildFlags = [
    "-I${openems}/include"
    "-L${openems}/lib"
    "-R${openems}/lib"
  ];

  sourceRoot = "${src.name}/python";

  meta = {
    description = "Python interface to CSXCAD";
    homepage = "http://openems.de/index.php/Main_Page.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthuszagh ];
    platforms = lib.platforms.linux;
  };
}
