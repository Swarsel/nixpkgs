{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "chess";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "niklasf";
    repo = "python-${pname}";
    tag = "v${version}";
    hash = "sha256-8LOp4HQI9UOdaj4/jwd79ftdnaO4HtzMVf1cwcYFCiA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "chess" ];

  meta = {
    description = "Chess library with move generation, move validation, and support for common formats";
    homepage = "https://github.com/niklasf/python-chess";
    changelog = "https://github.com/niklasf/python-chess/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ smancill ];
  };
}
