{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "rfc3987";
  version = "1.3.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d3c4d257a560d544e9826b38bc81db676890c79ab9d7ac92b39c7a253d5ca733";
  };

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Parsing and validation of URIs (RFC 3986) and IRIs (RFC 3987)";
    homepage = "https://pypi.org/project/rfc3987/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vanschelven ];
  };
}
