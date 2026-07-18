{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  python,
}:

buildPythonPackage rec {
  pname = "gpxpy";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "gpxpy";
    rev = "v${version}";
    hash = "sha256-s65k0u4LIwHX9RJMJIYMkNS4/Z0wstzqYVPAjydo2iI=";
  };

  propagatedBuildInputs = [ lxml ];

  checkPhase = ''
    ${python.interpreter} -m unittest test
  '';

  format = "setuptools";

  meta = {
    description = "Python GPX (GPS eXchange format) parser";
    homepage = "https://github.com/tkrajina/gpxpy";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "gpxinfo";
  };
}
