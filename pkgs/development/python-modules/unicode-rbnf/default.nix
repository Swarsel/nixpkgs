{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "unicode-rbnf";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "unicode-rbnf";
    tag = "v${version}";
    hash = "sha256-t5QHZVBIRVyhqmgVno3Nql6W0Q91DZ8sJA+nFBdKkj4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "unicode_rbnf" ];

  meta = {
    description = "Pure Python implementation of ICU's rule-based number format engine";
    homepage = "https://github.com/rhasspy/unicode-rbnf";
    changelog = "https://github.com/rhasspy/unicode-rbnf/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
