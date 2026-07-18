{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # test dependencies
  pytestCheckHook,
  # build system
  setuptools,
}:
let
  pname = "lazy-imports";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "bachorp";
    repo = "lazy-imports";
    tag = version;
    hash = "sha256-3TKhPMtViebdFTR3timf0ulXMdKrpQZ22gj891xQHVI=";
  };
in
buildPythonPackage {
  inherit pname version src;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lazy_imports" ];

  meta = {
    description = "Utility package to create lazy modules, deferring associated imports until attribute access";
    homepage = "https://github.com/bachorp/lazy-imports";
    changelog = "https://github.com/bachorp/lazy-imports/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
