{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  opencv-python,
  scikit-image,
  setuptools,
}:

buildPythonPackage rec {
  pname = "imagecorruptions";
  version = "1.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "044e173f24d5934899bdbf3596bfbec917e8083e507eed583ab217abebbe084d";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scikit-image
    opencv-python
  ];

  pyproject = true;
  pythonImportsCheck = [ "imagecorruptions" ];

  meta = {
    description = "This package provides a set of image corruptions";
    homepage = "https://github.com/bethgelab/imagecorruptions";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rakesh4g ];
  };
}
