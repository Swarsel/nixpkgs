{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "standard-imghdr";
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
  pythonImportsCheck = [ "imghdr" ];
  sourceRoot = "${src.name}/imghdr";

  meta = {
    description = "Python dead batteries. See PEP 594";
    homepage = "https://github.com/youknowone/python-deadlib";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
