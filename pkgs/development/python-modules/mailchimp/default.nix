{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "mailchimp";
  version = "2.0.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "5227999904233a7d2e9ce5eac5225b9a5fac0318ae5107e3ed09c8bf89286768";
  };

  buildInputs = [ docopt ];
  propagatedBuildInputs = [ requests ];
  format = "setuptools";

  patchPhase = ''
    sed -i 's/==/>=/' setup.py
  '';

  meta = {
    description = "CLI client and Python API library for the MailChimp email platform";
    homepage = "http://apidocs.mailchimp.com/api/2.0/";
    license = lib.licenses.mit;
  };
}
