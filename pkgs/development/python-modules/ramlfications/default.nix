{
  lib,
  attrs,
  buildPythonPackage,
  click,
  fetchPypi,
  jsonref,
  markdown2,
  mock,
  pytest,
  pytest-localserver,
  pytest-mock,
  pytest-server-fixtures,
  pyyaml,
  six,
  termcolor,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "ramlfications";
  version = "0.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wcQd5j74y7d0xFeWlwlhceZj95ixUmv5upnv/6Rl1ew=";
  };

  # [darwin]  AssertionError: Expected 'update_mime_types' to have been called once. Called 0 times.
  buildInputs = [
    mock
    pytest
    pytest-mock
    pytest-server-fixtures
    pytest-localserver
  ];

  propagatedBuildInputs = [
    termcolor
    click
    markdown2
    six
    jsonref
    pyyaml
    xmltodict
    attrs
  ];

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python RAML parser";
    homepage = "https://ramlfications.readthedocs.org";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "ramlfications";
  };
}
