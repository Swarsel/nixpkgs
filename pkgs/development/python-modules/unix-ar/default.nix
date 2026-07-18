{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "unix-ar";
  version = "0.2.1";

  src = fetchPypi {
    inherit format version;
    hash = "sha256-Kstxi8Ewi/gOW52iYU2CQswv475M2LL9Rxm84Ymq/PE=";
    pname = "unix_ar";
  };

  format = "wheel";

  meta = {
    description = "AR file handling for Python (including .deb files)";
    homepage = "https://github.com/getninjas/unix_ar";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tirimia ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
