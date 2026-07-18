{
  lib,
  buildPythonPackage,
  fetchPypi,
  six,
}:

buildPythonPackage rec {
  pname = "twiggy";
  version = "0.5.1";

  src = fetchPypi {
    inherit version;
    sha256 = "7938840275972f6ce89994a5bdfb0b84f0386301a043a960af6364952e78ffe4";
    pname = "Twiggy";
  };

  propagatedBuildInputs = [ six ];
  doCheck = false;
  format = "setuptools";

  meta = {
    # Taken from http://i.wearpants.org/blog/meet-twiggy/
    description = "Twiggy is the first totally new design for a logger since log4j";
    homepage = "http://twiggy.wearpants.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pierron ];
  };
}
