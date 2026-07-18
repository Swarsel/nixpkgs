{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  keyring,
  lxml,
  ofxhome,
  ofxparse,
}:

buildPythonPackage rec {
  pname = "ofxclient";
  version = "2.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0jdhqsbl34yn3n0x6mwsnl58c25v5lp6vr910c2hk7l74l5y7538";
  };

  propagatedBuildInputs = [
    ofxhome
    ofxparse
    beautifulsoup4
    lxml
    keyring
  ];

  # ImportError: No module named tests
  doCheck = false;
  format = "setuptools";

  patchPhase = ''
    substituteInPlace setup.py --replace '"argparse",' ""
  '';

  meta = {
    description = "OFX client for dowloading transactions from banks";
    homepage = "https://github.com/captin411/ofxclient";
    license = lib.licenses.mit;
    mainProgram = "ofxclient";
  };
}
