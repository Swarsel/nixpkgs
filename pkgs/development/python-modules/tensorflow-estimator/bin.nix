{
  lib,
  absl-py,
  buildPythonPackage,
  fetchPypi,
  mock,
  numpy,
}:

buildPythonPackage rec {
  pname = "tensorflow-estimator";
  version = "2.15.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-rt8h7sf7LckRUPyRoc4SvETbtyJ4oItY55/4fJ4o8VM=";
    format = "wheel";
    pname = "tensorflow_estimator";
  };

  propagatedBuildInputs = [
    mock
    numpy
    absl-py
  ];

  format = "wheel";

  meta = {
    description = "TensorFlow Estimator is a high-level API that encapsulates model training, evaluation, prediction, and exporting";
    homepage = "http://tensorflow.org";
    license = lib.licenses.asl20;
  };
}
