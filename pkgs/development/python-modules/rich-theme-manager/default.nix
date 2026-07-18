{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "rich-theme-manager";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "RhetTbull";
    repo = "rich_theme_manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nSNG+lWOPmh66I9EmPvWqbeceY/cu+zBpgVlDTNuHc0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ rich ];
  pyproject = true;
  pythonImportsCheck = [ "rich_theme_manager" ];

  meta = {
    description = "Define custom styles and themes for use with rich";
    homepage = "https://github.com/RhetTbull/rich_theme_manager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
