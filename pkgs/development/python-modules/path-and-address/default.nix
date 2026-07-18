{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
}:

buildPythonPackage rec {
  pname = "path-and-address";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "joeyespo";
    repo = "path-and-address";
    rev = "v${version}";
    sha256 = "0b0afpsaim06mv3lhbpm8fmawcraggc11jhzr6h72kdj1cqjk5h6";
  };

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  format = "setuptools";

  meta = {
    description = "Functions for server CLI applications used by humans";
    homepage = "https://github.com/joeyespo/path-and-address";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
  };
}
