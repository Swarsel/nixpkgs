{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cloudpathlib,
  confection,
  httpx,
  # passthru
  nix-update-script,
  pydantic,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  smart-open,
  srsly,
  typer,
  wasabi,
}:

buildPythonPackage (finalAttrs: {
  pname = "weasel";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "weasel";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-yiLoLdnDfKby1Ez1hKGL9DxazQto57Zn0DlRmGLurOs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cloudpathlib
    confection
    httpx
    pydantic
    smart-open
    srsly
    typer
    wasabi
  ];

  disabledTests = [
    # These tests require internet access
    "test_project_assets"
    "test_project_git_dir_asset"
    "test_project_git_file_asset"

    # configparser.InterpolationMissingOptionError: Bad value substitution: option 'commands' in
    # section 'project' contains an interpolation key 'vars.b.e' which is not a valid option name.
    # Raw value: '[{"name": "x", "script": ["hello ${vars.a} ${vars.b.e}"]}]'
    "test_project_config_interpolation"
  ];

  pyproject = true;
  pythonImportsCheck = [ "weasel" ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release-v(.*)"
      ];
    };
  };

  meta = {
    description = "Small and easy workflow system";
    homepage = "https://github.com/explosion/weasel/";
    changelog = "https://github.com/explosion/weasel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "weasel";
  };
})
