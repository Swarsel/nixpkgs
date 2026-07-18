{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "standard-pipes";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-vhGFTd1yXL4Frqli5D1GwOatwByDjvcP8sxgkdu6Jqg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pipes" ];
  sourceRoot = "${src.name}/pipes";

  meta = {
    description = "Standard library pipes redistribution";
    homepage = "https://github.com/youknowone/python-deadlib/tree/main/pipes";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
