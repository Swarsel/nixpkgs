{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  webencodings,
}:

buildPythonPackage rec {
  pname = "tinyhtml5";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "CourtBouillon";
    repo = "tinyhtml5";
    tag = version;
    hash = "sha256-PSDlCLPK3JVMq5dyt6xzNb4xx3F8Jwf8HAgYLKoXH+E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  dependencies = [
    webencodings
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tinyhtml5"
  ];

  meta = {
    description = "Tiny HTML5 parser";
    homepage = "https://github.com/CourtBouillon/tinyhtml5";
    changelog = "https://github.com/CourtBouillon/tinyhtml5/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
