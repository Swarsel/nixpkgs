{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "netifaces";
  version = "0.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BDp5FG6ykH7fQ5iZ8mKz3+QXF9NBJCmO0oETmouTyjI=";
  };

  # No tests implemented
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "netifaces" ];

  meta = {
    description = "Portable access to network interfaces from Python";
    homepage = "https://github.com/al45tair/netifaces";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
