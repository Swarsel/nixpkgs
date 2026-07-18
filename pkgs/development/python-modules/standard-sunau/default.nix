{
  lib,
  fetchFromGitHub,
  audioop-lts,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "standard-sunau";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-vhGFTd1yXL4Frqli5D1GwOatwByDjvcP8sxgkdu6Jqg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    audioop-lts
  ];

  pyproject = true;
  pythonImportsCheck = [ "sunau" ];
  sourceRoot = "${src.name}/sunau";

  meta = {
    description = "Standard library sunau redistribution";
    homepage = "https://github.com/youknowone/python-deadlib/tree/main/sunau";
    license = lib.licenses.psfl;
    maintainers = [ ];
  };
}
