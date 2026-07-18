{
  lib,
  adb-homeassistant,
  buildPythonPackage,
  fetchPypi,
  flask,
  pure-python-adb-homeassistant,
  pycryptodome,
  pyyaml,
  rsa,
}:
buildPythonPackage rec {
  pname = "firetv";
  version = "1.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "602de77411c2caffb322e4ff63fa6cc4eeb9a50c5f4b14e13930ed7cd87cf513";
  };

  propagatedBuildInputs = [
    adb-homeassistant
    flask
    pure-python-adb-homeassistant
    pycryptodome
    pyyaml
    rsa
  ];

  # No Tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Communicate with an Amazon Fire TV device via ADB over a network";
    homepage = "https://github.com/happyleavesaoc/python-firetv/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.makefu ];
    mainProgram = "firetv-server";
  };
}
