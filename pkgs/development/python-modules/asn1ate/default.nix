{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
}:

buildPythonPackage rec {
  pname = "asn1ate";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "schneider-electric";
    repo = "asn1ate";
    rev = "v${version}";
    sha256 = "1p8hv4gsyqsdr0gafcq497n52pybiqmc22di8ai4nsj60fv0km45";
  };

  propagatedBuildInputs = [ pyparsing ];
  format = "setuptools";

  meta = {
    description = "Python library for translating ASN.1 into other forms";
    homepage = "https://github.com/schneider-electric/asn1ate";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "asn1ate";
  };
}
