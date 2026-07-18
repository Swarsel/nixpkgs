{
  lib,
  buildPythonPackage,
  dmenu,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dmenu-python";
  version = "0.2.1";

  src = fetchPypi {
    inherit version;
    sha256 = "06v2fq0ciallbib7sbk4kncj0n3gdqp1kz8n5k2669x49wyh34wm";
    pname = "dmenu";
  };

  propagatedBuildInputs = [ dmenu ];
  # No tests existing
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python wrapper for dmenu";
    homepage = "https://dmenu.readthedocs.io";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nico202 ];
  };
}
