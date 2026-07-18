{
  lib,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
  pythonAtLeast,
  requests,
  six,
}:

buildPythonPackage rec {
  pname = "hypchat";
  version = "0.21";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1sd8f3gihagaqd848dqy6xw457fa4f9bla1bfyni7fq3h76sjdzg";
  };

  propagatedBuildInputs = [
    requests
    six
    python-dateutil
  ];

  disabled = pythonAtLeast "3.12";
  format = "setuptools";

  meta = {
    license = lib.licenses.mit;
  };
}
