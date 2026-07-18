{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  regex,
}:

buildPythonPackage rec {
  pname = "pygrok";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "garyelephant";
    repo = "pygrok";
    rev = "v${version}";
    sha256 = "07487rcmv74srnchh60jp0vg46g086qmpkaj8gxqhp9rj47r1s4m";
  };

  propagatedBuildInputs = [ regex ];
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';

  format = "setuptools";

  meta = {
    description = "Python implementation of jordansissel's grok regular expression library";
    homepage = "https://github.com/garyelephant/pygrok";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ winpat ];
    platforms = lib.platforms.unix;
  };
}
