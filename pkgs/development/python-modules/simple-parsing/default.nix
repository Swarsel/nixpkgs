{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  docstring-parser,
  # build-system
  hatchling,
  # tests
  matplotlib,
  numpy,
  orion,
  pytest-benchmark,
  pytest-regressions,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  # optional-dependencies
  tomli,
  tomli-w,
  typing-extensions,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "simple-parsing";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "lebrice";
    repo = "SimpleParsing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Nsr+I+BoVxockRGQAjG+ushRQ4CtWgkHrg5aVorSrvw=";
  };

  nativeCheckInputs = [
    matplotlib
    numpy
    orion
    pytest-benchmark
    pytest-regressions
    pytestCheckHook
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    docstring-parser
    typing-extensions
  ];

  disabledTests = [
    # AssertionError
    # https://github.com/lebrice/SimpleParsing/issues/338
    "test_bool_args_in_help"
    "test_desc_from_cls_docstring"
    "test_docstring_builds_upon_bases"
    "test_help_string"
    "test_help_string_displays_default_factory_arguments"
    "test_help_takes_value_from_docstring"
    "test_issue_48"
    "test_running_example_outputs_expected_without_arg"
    "test_subgroup_partial_with_nested_field"
    "test_weird_docstring_with_field_like"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # AssertionError ("usagepython314mpytesthmixed..." != "usagepython314mpytesthmixed")
    "test_each_type_is_used_correctly"
    "test_issue_46"
    "test_issue_46_solution2"

    # TypeError: dest= is required for options like '---------'
    "test_pass_invalid_value_to_add_config_path_arg"
  ];

  optional-dependencies = {
    toml = [
      tomli
      tomli-w
    ];

    yaml = [ pyyaml ];
  };

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "simple_parsing" ];

  meta = {
    description = "Simple, Elegant, Typed Argument Parsing with argparse";
    homepage = "https://github.com/lebrice/SimpleParsing";
    changelog = "https://github.com/lebrice/SimpleParsing/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
