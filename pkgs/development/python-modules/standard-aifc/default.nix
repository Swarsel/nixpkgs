{
  lib,
  fetchFromGitHub,
  audioop-lts,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  standard-chunk,
}:

buildPythonPackage rec {
  pname = "standard-aifc";
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
    standard-chunk
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aifc"
  ];

  sourceRoot = "${src.name}/aifc";

  meta = {
    description = "Standard library aifc redistribution";
    homepage = "https://github.com/youknowone/python-deadlib/tree/main/aifc";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
