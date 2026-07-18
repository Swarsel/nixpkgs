{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pyzmq,
  twisted,
}:

buildPythonPackage rec {
  pname = "txzmq";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jWB9C/CcqUYAuOQvByHb5D7lOgRwGCNErHrOfljcYXc=";
    pname = "txZMQ";
  };

  propagatedBuildInputs = [
    pyzmq
    twisted
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "txzmq" ];

  meta = {
    description = "Twisted bindings for ZeroMQ";
    homepage = "https://github.com/smira/txZMQ";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}
