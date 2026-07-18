{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
}:

buildPythonPackage rec {
  pname = "ibis";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "dmulholl";
    repo = "ibis";
    rev = version;
    hash = "sha256-9ELOAQhD6KXyTN2U0lGmNxxSzx9o2QIt+CNa6i8o5xs=";
  };

  checkPhase = ''
    ${python.interpreter} test_ibis.py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "ibis" ];

  meta = {
    description = "Lightweight template engine";
    homepage = "https://github.com/dmulholland/ibis";
    license = lib.licenses.publicDomain;
    maintainers = [ ];
  };
}
