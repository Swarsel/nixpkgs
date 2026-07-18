{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "translationstring";
  version = "1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "bf947538d76e69ba12ab17283b10355a9ecfbc078e6123443f43f2107f6376f3";
  };

  format = "setuptools";

  meta = {
    description = "Utility library for i18n relied on by various Repoze and Pyramid packages";
    homepage = "https://pylonsproject.org/";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
