{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  protobuf,
  python-axolotl-curve25519,
}:

buildPythonPackage rec {
  pname = "python-axolotl";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1bwdp24fmriffwx91aigs9k162albb51iskp23nc939z893q23py";
  };

  propagatedBuildInputs = [
    cryptography
    python-axolotl-curve25519
    protobuf
  ];

  format = "setuptools";

  meta = {
    description = "Python port of libaxolotl-android";
    homepage = "https://github.com/tgalal/python-axolotl";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
