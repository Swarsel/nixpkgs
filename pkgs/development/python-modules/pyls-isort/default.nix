{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isort,
  python-lsp-server,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyls-isort";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "paradoxxxzero";
    repo = "pyls-isort";
    tag = "v${version}";
    sha256 = "0xba0aiyjfdi9swjzxk26l94dwlwvn17kkfjfscxl8gvspzsn057";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    isort
    python-lsp-server
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyls_isort" ];

  meta = {
    description = "Isort plugin for python-lsp-server";
    homepage = "https://github.com/paradoxxxzero/pyls-isort";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
