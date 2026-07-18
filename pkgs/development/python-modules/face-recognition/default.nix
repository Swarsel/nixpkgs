{
  lib,
  buildPythonPackage,
  # propagates
  click,
  config,
  dlib,
  face-recognition-models,
  fetchPypi,
  numpy,
  pillow,
  # tests
  pytestCheckHook,
  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage rec {
  pname = "face-recognition";
  version = "1.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Xl790WhqpWavDTzBMTsTHksZdleo/9A2aebT+tknBew=";
    pname = "face_recognition";
  };

  propagatedBuildInputs = [
    click
    dlib
    face-recognition-models
    numpy
    pillow
  ];

  # Disables tests when running with cuda due to https://github.com/NixOS/nixpkgs/issues/225912
  doCheck = !config.cudaSupport;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "World's simplest facial recognition api for Python and the command line";
    homepage = "https://github.com/ageitgey/face_recognition";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
