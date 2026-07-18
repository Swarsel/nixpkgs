{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyasn1,
  pyopenssl,
}:

buildPythonPackage rec {
  pname = "ndg-httpsclient";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "cedadev";
    repo = "ndg_httpsclient";
    rev = version;
    sha256 = "0lhsgs4am4xyjssng5p0vkfwqncczj1dpa0vss4lrhzq86mnn5rz";
  };

  propagatedBuildInputs = [
    pyasn1
    pyopenssl
  ];

  # uses networking
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Provide enhanced HTTPS support for httplib and urllib2 using PyOpenSSL";
    homepage = "https://github.com/cedadev/ndg_httpsclient/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "ndg_httpclient";
  };
}
