{
  lib,
  fetchFromGitHub,
  # dependencies
  beautifulsoup4,
  buildPythonPackage,
  # tests
  click,
  # build-system
  hatchling,
  mkdocs,
  playwright,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-swagger-ui-tag";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "Blueswen";
    repo = "mkdocs-swagger-ui-tag";
    tag = "v${version}";
    hash = "sha256-5bQJMmPrweIAR42bjfWHUqnSy4IFoTpFoBaV+Gj/OGI=";
  };

  nativeCheckInputs = [
    click
    mkdocs
    playwright
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    beautifulsoup4
  ];

  disabledTests = [
    # Don't actually build results
    "test_material"
    "test_material_dark_scheme_name"
    "test_template"
    "test_mkdocs_screenshot"
    "test_no_console_errors"

    # ValueError: I/O operation on closed file
    "test_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_swagger_ui_tag" ];

  meta = {
    description = "MkDocs plugin supports for add Swagger UI in page";
    homepage = "https://github.com/Blueswen/mkdocs-swagger-ui-tag";
    changelog = "https://github.com/blueswen/mkdocs-swagger-ui-tag/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ snpschaaf ];
  };
}
