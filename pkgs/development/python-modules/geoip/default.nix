{
  lib,
  buildPythonPackage,
  fetchPypi,
  libgeoip,
  setuptools,
}:

buildPythonPackage rec {
  pname = "geoip";
  version = "1.3.2";

  src = fetchPypi {
    inherit version;
    sha256 = "1rphxf3vrn8wywjgr397f49s0s22m83lpwcq45lm0h2p45mdm458";
    pname = "GeoIP";
  };

  propagatedBuildInputs = [ libgeoip ];
  # Tests cannot be run because they require data that isn't included in the
  # release tarball.
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "MaxMind GeoIP Legacy Database - Python API";
    homepage = "https://www.maxmind.com/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
