{
  lib,
  buildPythonPackage,
  fetchPypi,

  # extra: websocket
  websocket-client,
}:

buildPythonPackage rec {
  pname = "samsungctl";
  version = "0.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ipz3fd65rqkxlb02sql0awc3vnslrwb2pfrsnpfnf8bfgxpbh9g";
  };

  # no tests
  doCheck = false;
  format = "setuptools";

  optional-dependencies = {
    websocket = [ websocket-client ];
    # interactive_ui requires curses package
  };

  pythonImportsCheck = [ "samsungctl" ];

  meta = {
    description = "Remote control Samsung televisions via a TCP/IP connection";
    homepage = "https://github.com/Ape/samsungctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "samsungctl";
  };
}
