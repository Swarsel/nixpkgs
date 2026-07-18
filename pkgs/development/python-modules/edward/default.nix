{
  lib,
  buildPythonPackage,
  fetchPypi,
  keras,
  numpy,
  scipy,
  six,
  tensorflow,
}:

buildPythonPackage rec {
  pname = "edward";
  version = "1.3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "3818b39e77c26fc1a37767a74fdd5e7d02877d75ed901ead2f40bd03baaa109f";
  };

  propagatedBuildInputs = [
    keras
    numpy
    scipy
    six
    tensorflow
  ];

  # disabled for now due to Tensorflow trying to create files in $HOME:
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Probabilistic programming language using Tensorflow";
    homepage = "https://github.com/blei-lab/edward";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
