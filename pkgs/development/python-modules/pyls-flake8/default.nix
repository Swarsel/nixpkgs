{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flake8,
  python-lsp-server,
}:

buildPythonPackage rec {
  pname = "pyls-flake8";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "emanspeaks";
    repo = "pyls-flake8";
    rev = "v${version}";
    sha256 = "14wkmwh8mqr826vdzxhvhdwrnx2akzmnbv3ar391qs4imwqfjx3l";
  };

  propagatedBuildInputs = [
    flake8
    python-lsp-server
  ];

  format = "setuptools";

  meta = {
    description = "Flake8 plugin for the Python LSP Server";
    homepage = "https://github.com/emanspeaks/pyls-flake8";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
