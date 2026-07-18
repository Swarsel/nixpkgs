{
  lib,
  buildPythonPackage,
  drawille,
  fetchPypi,
  matplotlib,
}:

buildPythonPackage rec {
  pname = "drawilleplot";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZEDroo7KkI2VxdESb2QDX+dPY4UahuuK9L0EddrxJjQ=";
  };

  propagatedBuildInputs = [
    drawille
    matplotlib
  ];

  doCheck = false; # does not have any tests at all
  format = "setuptools";
  pythonImportsCheck = [ "drawilleplot" ];

  meta = {
    description = "Matplotlib backend for graph output in unicode terminals using drawille";
    homepage = "https://github.com/gooofy/drawilleplot";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nobbz ];
    platforms = lib.platforms.all;
  };
}
