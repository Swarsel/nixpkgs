{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytest,
  transitions,
}:

buildPythonPackage rec {
  pname = "dissononce";
  version = "0.34.3";

  src = fetchFromGitHub {
    owner = "tgalal";
    repo = "dissononce";
    rev = version;
    sha256 = "0hn64qfr0d5npmza6rjyxwwp12k2z2y1ma40zpl104ghac6g3mbs";
  };

  propagatedBuildInputs = [
    cryptography
    transitions
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    HOME=$(mktemp -d) py.test tests/
  '';

  format = "setuptools";

  meta = {
    description = "Python implementation for Noise Protocol Framework";
    homepage = "https://pypi.org/project/dissononce/";
    license = lib.licenses.mit;
  };
}
