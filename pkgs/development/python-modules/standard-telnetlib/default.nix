{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "standard-telnetlib";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-vhGFTd1yXL4Frqli5D1GwOatwByDjvcP8sxgkdu6Jqg=";
  };

  # missing "reads" fixture when using pytest
  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "telnetlib" ];
  sourceRoot = "${src.name}/telnetlib";

  meta = {
    description = "Python dead batteries. See PEP 594";
    homepage = "https://github.com/youknowone/python-deadlib";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
