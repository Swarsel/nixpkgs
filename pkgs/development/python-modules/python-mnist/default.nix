{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "python-mnist";
  version = "0.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a0cced01e83b5b844cff86109280df7a672a8e4e38fc19fa68999a17f8a9fbd8";
  };

  format = "setuptools";

  meta = {
    description = "Simple MNIST data parser written in Python";
    homepage = "https://github.com/sorki/python-mnist";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
}
