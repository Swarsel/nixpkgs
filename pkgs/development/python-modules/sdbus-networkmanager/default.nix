{
  lib,
  buildPythonPackage,
  fetchPypi,
  sdbus,
}:

let
  pname = "sdbus-networkmanager";
  version = "2.0.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NXKsOoGJxoPsBBassUh2F3Oo8Iga09eLbW9oZO/5xQs=";
  };

  propagatedBuildInputs = [ sdbus ];
  format = "setuptools";

  meta = {
    description = "Python-sdbus binds for NetworkManager";
    homepage = "https://github.com/python-sdbus/python-sdbus-networkmanager";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ camelpunch ];
    platforms = lib.platforms.linux;
  };
}
