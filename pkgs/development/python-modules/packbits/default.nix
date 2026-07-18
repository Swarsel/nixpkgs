{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "packbits";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "bc6b370bb34e04ac8cfa835e06c0484380affc6d593adb8009dd6c0f7bfff034";
  };

  format = "setuptools";

  meta = {
    description = "PackBits encoder/decoder for Python";
    homepage = "https://github.com/psd-tools/packbits";
    license = [ lib.licenses.mit ];
  };
}
