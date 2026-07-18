{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyuca";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "jtauber";
    repo = "pyuca";
    rev = "v${version}";
    hash = "sha256-KIWk+/o1MX5J9cO7xITvjHrYg0NdgdTetOzfGVwAI/4=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pyuca" ];

  meta = {
    description = "Python implementation of the Unicode Collation Algorithm";
    homepage = "https://github.com/jtauber/pyuca";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
