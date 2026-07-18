{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  matplotlib,
}:

buildPythonPackage rec {
  pname = "pycocotools";
  version = "2.0.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NCVNdtqFV2/K9cHzqpquFrjLFUGDNLpCg7gAeWvRmT0=";
  };

  propagatedBuildInputs = [
    cython
    matplotlib
  ];

  # has no tests
  doCheck = false;
  format = "setuptools";

  pythonImportsCheck = [
    "pycocotools.coco"
    "pycocotools.cocoeval"
  ];

  meta = {
    description = "Official APIs for the MS-COCO dataset";
    homepage = "https://github.com/cocodataset/cocoapi/tree/master/PythonAPI";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ piegames ];
  };
}
