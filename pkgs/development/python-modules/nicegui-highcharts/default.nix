{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  hatchling,
  nicegui,
}:

buildPythonPackage (finalAttrs: {
  pname = "nicegui-highcharts";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "zauberzeug";
    repo = "nicegui-highcharts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QvhvQU/na33ZYQbAuCJvsVDDRkTy+Z4STJg9vlZrQbY=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    docutils
    nicegui
  ];

  pyproject = true;
  pythonImportsCheck = [ "nicegui_highcharts" ];
  pythonRelaxDeps = [ "docutils" ];

  meta = {
    description = "NiceGUI with support for Highcharts";
    homepage = "https://github.com/zauberzeug/nicegui-highcharts";
    changelog = "https://github.com/zauberzeug/nicegui-highcharts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
