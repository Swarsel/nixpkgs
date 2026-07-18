{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "gntp";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1q6scs8lp84v0aph6b5c9jhv51rhq2vmzpdd38db92ybkq0g597l";
  };

  # requires a growler service to be running
  doCheck = false;
  format = "setuptools";

  pythonImportsCheck = [
    "gntp"
    "gntp.notifier"
  ];

  meta = {
    description = "Python library for working with the Growl Notification Transport Protocol";
    homepage = "https://github.com/kfdm/gntp/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jfroche ];
    mainProgram = "gntp";
  };
}
