{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  six,
}:

buildPythonPackage rec {
  pname = "mplleaflet";
  version = "0.0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "049e0b91797ce5b462853395138161fed9e8dfc1f4723f482ebb0739a0bbd289";
  };

  propagatedBuildInputs = [
    jinja2
    six
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Convert Matplotlib plots into Leaflet web maps";
    homepage = "https://github.com/jwass/mplleaflet";
    license = with lib.licenses; [ bsd3 ];
  };
}
