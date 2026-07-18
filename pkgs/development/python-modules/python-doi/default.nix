{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "python-doi";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "papis";
    repo = "python-doi";
    rev = "v${version}";
    sha256 = "sha256-c5Wo/bJuHwAG7XOy4Re9joYw14jWZ6QaRB4Wsk8StL0=";
  };

  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Python library to work with Document Object Identifiers (doi)";
    homepage = "https://github.com/papis/python-doi";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ teto ];
  };
}
