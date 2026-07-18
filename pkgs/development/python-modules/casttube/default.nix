{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "casttube";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "10pw2sjy648pvp42lbbdmkkx79bqlkq1xcbzp1frraj9g66azljl";
  };

  propagatedBuildInputs = [ requests ];
  # no tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Interact with the Youtube Chromecast api";
    homepage = "https://github.com/ur1katz/casttube";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fpletz ];
  };
}
