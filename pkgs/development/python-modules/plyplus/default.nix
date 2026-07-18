{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  ply,
}:
buildPythonPackage rec {
  pname = "plyplus";
  version = "0.7.5";

  src = fetchPypi {
    inherit version;
    sha256 = "0g3flgfm3jpb2d8v9z0qmbwca5gxdqr10cs3zvlfhv5cs06ahpnp";
    pname = "PlyPlus";
  };

  propagatedBuildInputs = [ ply ];
  doCheck = !isPy3k;
  format = "setuptools";

  meta = {
    description = "General-purpose parser built on top of PLY";
    homepage = "https://github.com/erezsh/plyplus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ twey ];
  };
}
