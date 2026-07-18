{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  standard-aifc,
}:

buildPythonPackage rec {
  pname = "standard-sndhdr";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-vhGFTd1yXL4Frqli5D1GwOatwByDjvcP8sxgkdu6Jqg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    standard-aifc
  ];

  pyproject = true;
  pythonImportsCheck = [ "sndhdr" ];
  sourceRoot = "${src.name}/sndhdr";

  meta = {
    description = "Standard library sndhdr redistribution";
    homepage = "https://github.com/youknowone/python-deadlib/tree/main/sndhdr";
    license = lib.licenses.psfl;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
