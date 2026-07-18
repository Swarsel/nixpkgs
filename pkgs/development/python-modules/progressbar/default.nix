{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "progressbar";
  version = "2.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "5d81cb529da2e223b53962afd6c8ca0f05c6670e40309a7219eacc36af9b6c63";
  };

  # invalid command 'test'
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Text progressbar library for python";
    homepage = "https://pypi.org/project/progressbar/";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
})
