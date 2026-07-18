{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "linode";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "db3c2a7fab8966d903a63f16c515bff241533e4ef2d746aa7aae4a49bba5e573";
  };

  propagatedBuildInputs = [ requests ];
  format = "setuptools";

  meta = {
    description = "Thin python wrapper around Linode's API";
    homepage = "https://github.com/ghickman/linode";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
