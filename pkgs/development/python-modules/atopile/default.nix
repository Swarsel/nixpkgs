{
  lib,
  fetchFromGitHub,
  # deps
  antlr4-python3-runtime,
  atopile-easyeda2kicad,
  black,
  buildPythonPackage,
  case-converter,
  cmake,
  cookiecutter,
  dataclasses-json,
  deprecated,
  fastapi-github-oidc,
  fetchpatch,
  freetype-py,
  gitpython,
  hatch-vcs,
  # build-system
  hatchling,
  hypothesis,
  kicad-python,
  kicadcliwrapper,
  matplotlib,
  mcp,
  more-itertools,
  nanobind,
  natsort,
  ninja,
  numpy,
  ordered-set,
  pathvalidate,
  pint,
  posthog,
  psutil,
  pydantic-settings,
  pygls,
  pytest-benchmark,
  pytest-datafiles,
  pytest-timeout,
  pytest-xdist,
  # tests
  pytestCheckHook,
  pythonOlder,
  questionary,
  requests,
  rich,
  ruamel-yaml,
  ruff,
  scikit-build-core,
  semver,
  sexpdata,
  shapely,
  truststore,
  typer,
  urllib3,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zstd,
}:

buildPythonPackage (finalAttrs: {
  pname = "atopile";
  version = "0.12.5";

  src = fetchFromGitHub {
    owner = "atopile";
    repo = "atopile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/1vkYGG3OHyeFpzbvRoAxUtLQLePKE2jwQx8o/CTErQ=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  doCheck = true;

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    pytest-xdist
    pytest-benchmark
    pytest-datafiles
    pytest-timeout
    hypothesis
    versionCheckHook
  ];

  preCheck = ''
    # do not report worker logs to filee
    substituteInPlace test/conftest.py \
      --replace-fail "worker_id =" "worker_id = None #"

    # unrecognized flags
    substituteInPlace pyproject.toml \
      --replace-fail "--html=artifacts/test-report.html" "" \
      --replace-fail "--self-contained-html" "" \
      --replace-fail "--numprocesses=auto" "" \

    # Replace this function call that cause test to hang
    substituteInPlace            \
      test/cli/test_packages.py  \
      test/library/test_names.py \
      test/test_examples.py      \
      test/test_parse_utils.py   \
        --replace-fail "_repo_root()" "Path('$(pwd)')"

    # Fix crash due to empty list in fixture tests
    substituteInPlace            \
      test/test_examples.py      \
      test/test_parse_utils.py   \
        --replace-fail "p.stem" "p.stem if isinstance(p, Path) else p"
  '';

  build-system = [
    hatchling
    scikit-build-core
    hatch-vcs
    nanobind
  ];

  dependencies = [
    antlr4-python3-runtime
    atopile-easyeda2kicad
    black # used as a dependency
    case-converter
    cookiecutter
    dataclasses-json
    deprecated
    fastapi-github-oidc
    freetype-py
    gitpython
    kicad-python
    kicadcliwrapper
    matplotlib
    mcp
    more-itertools
    natsort
    numpy
    ordered-set
    pathvalidate
    pint
    posthog
    psutil
    pydantic-settings
    pygls
    questionary
    requests
    rich
    ruamel-yaml
    ruff
    semver
    sexpdata
    shapely
    truststore
    typer
    urllib3
    zstd
  ];

  disabled = pythonOlder "3.13";

  disabledTestMarks = [
    "slow"
    "not_in_ci"
    "regression"
  ];

  disabledTestPaths = [
    # timouts
    "test/test_cli.py"
    "test/cli/test_packages.py"
    "test/end_to_end/test_net_naming.py"
    "test/end_to_end/test_pcb_export.py"
    "test/exporters/bom/test_bom.py"
    "test/front_end/test_front_end_pick.py"
    "test/libs/picker/test_pickers.py"
  ];

  disabledTests = [
    # Timeout (>10.0s) from pytest-timeout.
    "test_build_error_logging"
    "test_can_evaluate_literals"
    "test_examples_build"
    "test_net_names_deterministic"
    "test_performance_mifs_bus_params"
    "test_regression_rp2040_usb_diffpair"
    "test_reserved_attrs"
    "test_resistor"
    "test_loooooong_chain"
    "test_parser_netlist"
    "test_dump_load_equality"
    "test_performance_mifs_connect_check"

    # requires internet
    "test_simple_pick"
    "test_simple_negative_pick"
    "test_jlcpcb_pick_resistor"
    "test_jlcpcb_pick_capacitor"
    "test_regression_rp2040_usb_diffpair_full"
    "test_model_translations"

    # FileNotFoundError: [Errno 2] No such file or directory: '/build/source/build/logs/latest'
    "test_muster_diamond_dependencies"
    "test_muster_disconnected_components"
    "test_muster_register_decorator"
    "test_muster_select_skips_targets_with_failed_dependencies"
    "test_muster_select_skips_targets_with_partial_failed_dependencies"
    "test_muster_select_yields_targets_with_all_successful_dependencies"
    "test_muster_specific_targets_with_dependencies"
  ];

  dontUseCmakeConfigure = true; # skip cmake configure invocation
  pyproject = true;

  pytestFlags = [
    "--timeout=10" # any test taking long, timouts with more than 60s
    "--benchmark-disable"
    "--tb=line"
  ];

  pythonImportsCheck = [ "atopile" ];

  pythonRelaxDeps = [
    "deprecated"
    "posthog"
    "prompt-toolkit"
  ];

  versionCheckProgramArg = "--version";

  meta = {
    description = "Design circuit boards with code";
    homepage = "https://atopile.io";
    changelog = "https://github.com/atopile/atopile/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "ato";
    downloadPage = "https://github.com/atopile/atopile";
  };
})
