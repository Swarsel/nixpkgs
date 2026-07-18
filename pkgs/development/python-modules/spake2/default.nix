{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "spake2";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "warner";
    repo = "python-spake2";
    tag = "v${version}";
    hash = "sha256-WPMGH1OzG+5O+2lNl2sv06/dNardY+BHYDS290Z36vQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "spake2" ];

  meta = {
    description = "SPAKE2 password-authenticated key exchange library";
    homepage = "https://github.com/warner/python-spake2";
    changelog = "https://github.com/warner/python-spake2/blob/v${version}/NEWS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
