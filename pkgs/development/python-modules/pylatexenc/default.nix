{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = "pylatexenc";
    rev = "v${version}";
    hash = "sha256-3Ho04qrmCtmmrR+BUJNbtdCZcK7lXhUGJjm4yfCTUkM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pylatexenc" ];

  meta = {
    description = "Simple LaTeX parser providing latex-to-unicode and unicode-to-latex conversion";
    homepage = "https://pylatexenc.readthedocs.io";
    changelog = "https://pylatexenc.readthedocs.io/en/latest/changes/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://www.github.com/phfaist/pylatexenc/releases";
  };
}
