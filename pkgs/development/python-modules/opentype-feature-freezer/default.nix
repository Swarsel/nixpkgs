{
  lib,
  fetchFromGitHub,
  biplist,
  buildPythonPackage,
  fonttools,
  gitUpdater,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "opentype-feature-freezer";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "twardoch";
    repo = "fonttools-opentype-feature-freezer";
    tag = "v${version}";
    hash = "sha256-8aJYQyUpcEOyzVHZ0LXfGJ1Tsxe5HICcfkFUdsI+/GI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    biplist
  ];

  build-system = [
    hatchling
  ];

  dependencies = [ fonttools ];

  disabledTestPaths = [
    # import file mismatch
    "src/opentype_feature_freezer/cli.py"
    # NameError: name 'defines' is not defined
    "app/dmgbuild_settings.py"
    # Missing module
    "app/OTFeatureFreezer.py"
  ];

  disabledTests = [
    # File not found
    "test_freeze"
    # AssertionError: assert '' == '# Scripts an...m,pnum,tnum\n'
    "test_report"
    # assert False
    "test_warn_substituting_glyphs_without_unicode"
  ];

  pyproject = true;
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Permanently \"apply\" OpenType features to fonts, by remapping their Unicode assignments";
    homepage = "https://github.com/twardoch/fonttools-opentype-feature-freezer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    mainProgram = "pyftfeatfreeze";
  };
}
