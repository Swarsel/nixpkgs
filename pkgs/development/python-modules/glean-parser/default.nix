{
  lib,
  buildPythonPackage,
  click,
  diskcache,
  fetchPypi,
  hatch-vcs,
  hatchling,
  jinja2,
  jsonschema,
  platformdirs,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "glean-parser";
  version = "19.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-oL2vnZWvaoZUPJb1IML0egeTU/ND/TsJqzC4fLnWyDY=";
    pname = "glean_parser";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    click
    diskcache
    jinja2
    jsonschema
    pyyaml
    platformdirs
  ];

  disabledTests = [
    # Network access
    "test_validate_ping"
    "test_logging"
    # Fails since yamllint 1.27.x
    "test_yaml_lint"
  ];

  pyproject = true;
  pythonImportsCheck = [ "glean_parser" ];

  meta = {
    description = "Tools for parsing the metadata for Mozilla's glean telemetry SDK";
    homepage = "https://github.com/mozilla/glean_parser";
    changelog = "https://github.com/mozilla/glean_parser/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "glean_parser";
  };
}
