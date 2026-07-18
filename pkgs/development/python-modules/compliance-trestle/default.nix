{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  cmarkgfm,
  cryptography,
  # tests
  datamodel-code-generator,
  defusedxml,
  furl,
  # build-system
  hatchling,
  ilcli,
  importlib-resources,
  jinja2,
  mypy,
  openpyxl,
  orjson,
  paramiko,
  pydantic,
  pytestCheckHook,
  python-dotenv,
  python-frontmatter,
  pythonAtLeast,
  requests,
  ruamel-yaml,
}:

let
  # nist-content is a git submodule, but using fetchSubmodules in src fails while recursing into
  # nist-content itself.
  # Thus we simply inject it after the fact in postPatch.
  nist-content = fetchFromGitHub {
    hash = "sha256-sDvNMheZZhk09YEfY5ocmZmAC3t3KenqD3PaNsi0mMU=";
    name = "nist-content";
    owner = "usnistgov";
    repo = "oscal-content";
    rev = "941c978d14c57379fbf6f7fb388f675067d5bff7";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "compliance-trestle";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "oscal-compass";
    repo = "compliance-trestle";
    tag = "v${finalAttrs.version}";
    # TODO: Try to fall back to fetchSubmodules at the next release
    # fetchSubmodules = true;
    hash = "sha256-4z+hJoykIwDRshtSyE94POy39cRNVqtT4L6KftNWG6w=";
  };

  postPatch = ''
    substituteInPlace tests/trestle/misc/mypy_test.py \
      --replace-fail "trestle'," "${placeholder "out"}/bin/trestle',"
  ''
  # Replace the expected nist-content git submodule with the pre-fetched path.
  + ''
    rmdir ./nist-content
    ln -s ${nist-content} ./nist-content
  '';

  nativeCheckInputs = [
    datamodel-code-generator
    mypy
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    attrs
    cmarkgfm
    cryptography
    defusedxml
    furl
    ilcli
    importlib-resources
    jinja2
    openpyxl
    orjson
    paramiko
    pydantic
    python-dotenv
    python-frontmatter
    requests
    ruamel-yaml
  ]
  ++ pydantic.optional-dependencies.email;

  disabledTestPaths = [
    # Requires network access
    "tests/trestle/core/remote"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # pydantic.v1.errors.ConfigError: unable to infer type for attribute "poam"
    "tests/trestle/core/models/interfaces_test.py"
    "tests/trestle/tasks/ocp4_cis_profile_to_oscal_catalog_test.py"
  ];

  disabledTests = [
    # Requires network access
    "test_import_from_url"
    "test_import_from_nist"
    "test_remote_profile_relative_cat"

    # AssertionError
    "test_profile_generate_assemble_rev_5"
    "test_ssp_assemble_fedramp_profile"
    "test_ssp_generate_aggregates_no_cds"
    "test_ssp_generate_aggregates_no_param_value_orig"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # AssertionError: assert 1 == 0
    # AttributeError: 'AliasTracker' object has no attribute 'aliases'
    "test_arguments"
    "test_get_list_cli"
    "test_load_custom_config"
    "test_load_default_config"
    "test_split_catalog_star"
    "test_split_comp_def"
  ];

  pyproject = true;
  pythonImportsCheck = [ "trestle" ];

  pythonRelaxDeps = [
    "cryptography"
  ];

  meta = {
    description = "Opinionated tooling platform for managing compliance as code, using continuous integration and NIST's OSCAL standard";
    homepage = "https://github.com/oscal-compass/compliance-trestle";
    changelog = "https://github.com/oscal-compass/compliance-trestle/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tochiaha ];
    mainProgram = "trestle";
  };
})
