{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "reparser";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "xmikos";
    repo = "reparser";
    rev = "v${version}";
    sha256 = "04v7h52wny0j2qj37501nk33j0s4amm134kagdicx2is49zylzq1";
  };

  # no tests implemented
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "reparser" ];

  meta = {
    description = "Simple regex-based lexer/parser for inline markup";
    homepage = "https://github.com/xmikos/reparser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
