{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "face-recognition-models";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-t5vSAKiMh8mp1EbJkK5xxaYm0fNzAXTm1XAVf/HYls8=";
    pname = "face_recognition_models";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools_80 ];
  pyproject = true;
  pythonImportsCheck = [ "face_recognition_models" ];

  meta = {
    description = "Trained models for the face_recognition python library";
    homepage = "https://github.com/ageitgey/face_recognition_models";
    license = lib.licenses.cc0;
    maintainers = [ ];
  };
})
