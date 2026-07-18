{
  lib,
  buildPythonPackage,
  fetchPypi,
  opencv4,
}:

buildPythonPackage rec {
  pname = "imutils";
  version = "0.5.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03827a9fca8b5c540305c0844a62591cf35a0caec199cb0f2f0a4a0fb15d8f24";
  };

  propagatedBuildInputs = [ opencv4 ];
  # no tests
  doCheck = false;
  format = "setuptools";

  pythonImportsCheck = [
    "imutils"
    "imutils.video"
    "imutils.io"
    "imutils.feature"
    "imutils.face_utils"
  ];

  meta = {
    description = "Series of convenience functions to make basic image processing functions";
    homepage = "https://github.com/jrosebr1/imutils";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "range-detector";
  };
}
