{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # tests
  pytestCheckHook,
  # dependencies
  sphinx,
}:

buildPythonPackage rec {
  pname = "hatch-sphinx";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "llimeht";
    repo = "hatch-sphinx";
    tag = "v${version}";
    hash = "sha256-8g0UkDMf05CVd2VbnV30pZpQ9chJhCkKfci7zmcIOoQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    hatchling
    sphinx
  ];

  disabledTests = [
    # /nix/store/62fdlzq1x1ak2lsxp4ij7ip5k9nia3hc-python3-3.13.7/bin/python3.13: No module named build
    "test_tool_apidoc"
    "test_tool_build"
    "test_tool_custom_lists_globs"
    "test_tool_custom_lists_noglobs"
    "test_tool_custom_strings"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hatch_sphinx" ];

  meta = {
    description = "Hatchling build plugin for Sphinx documentation";
    homepage = "https://github.com/llimeht/hatch-sphinx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
