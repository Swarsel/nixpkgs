{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  lxml,
  six,
}:

buildPythonPackage rec {
  pname = "ofxparse";
  version = "0.21";

  src = fetchPypi {
    inherit pname version;
    sha256 = "19y4sp5l9jqiqzzlbqdfiab42qx7d84n4xm4s7jfq397666vcyh5";
  };

  propagatedBuildInputs = [
    six
    beautifulsoup4
    lxml
  ];

  format = "setuptools";

  meta = {
    description = "Tools for working with the OFX (Open Financial Exchange) file format";
    homepage = "http://sites.google.com/site/ofxparse";
    license = lib.licenses.mit;
  };
}
